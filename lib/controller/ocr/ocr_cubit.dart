import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../service/ocr_service.dart';
import '../../service/permission_service.dart';
import '../../service/receipt_parser_service.dart';
import '../../service/ocr_gemini_service.dart';
import '../../model/ocr_result.dart';

import '../../util/app_locale.dart';
import '../../util/app_strings.dart';
import 'package:logger/logger.dart';

// OCR 상태
abstract class OcrState extends Equatable {
  const OcrState();

  @override
  List<Object?> get props => [];
}

// 초기 상태
class OcrInitial extends OcrState {}

// 이미지 선택 중
class OcrImageSelecting extends OcrState {}

// OCR 처리 중
class OcrProcessing extends OcrState {
  final File imageFile;

  const OcrProcessing(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

// OCR 완료 - 인식된 텍스트
class OcrTextRecognized extends OcrState {
  final String recognizedText;
  final File imageFile;

  const OcrTextRecognized({
    required this.recognizedText,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [recognizedText, imageFile];
}

// OCR 결과 생성 완료
class OcrResultGenerated extends OcrState {
  final OcrResult ocrResult;
  final File imageFile;

  const OcrResultGenerated({required this.ocrResult, required this.imageFile});

  @override
  List<Object?> get props => [ocrResult, imageFile];
}

// Gemini 분석 중
class OcrGeminiAnalyzing extends OcrState {
  final OcrResult ocrResult;
  final File imageFile;

  const OcrGeminiAnalyzing({required this.ocrResult, required this.imageFile});

  @override
  List<Object?> get props => [ocrResult, imageFile];
}

// Gemini 분석 완료
class OcrGeminiCompleted extends OcrState {
  final OcrResult ocrResult;
  final File imageFile;
  final Map<String, dynamic> geminiResult;

  const OcrGeminiCompleted({
    required this.ocrResult,
    required this.imageFile,
    required this.geminiResult,
  });

  @override
  List<Object?> get props => [ocrResult, imageFile, geminiResult];
}

// 에러 상태
class OcrError extends OcrState {
  final String message;

  const OcrError(this.message);

  @override
  List<Object?> get props => [message];
}

// OCR Cubit
class OcrCubit extends Cubit<OcrState> {
  final OcrService _ocrService;
  final PermissionService _permissionService;
  final ReceiptParserService _receiptParserService;
  final OcrGeminiService _ocrGeminiService;
  final Uuid _uuid = const Uuid();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  OcrCubit({
    OcrService? ocrService,
    PermissionService? permissionService,
    ReceiptParserService? receiptParserService,
    OcrGeminiService? ocrGeminiService,
  })  : _ocrService = ocrService ?? OcrService(),
        _permissionService = permissionService ?? PermissionService(),
        _receiptParserService = receiptParserService ?? ReceiptParserService(),
        _ocrGeminiService = ocrGeminiService ?? OcrGeminiService(),
        super(OcrInitial());

  // 갤러리에서 이미지 선택
  Future<void> selectImageFromGallery({AppLocale? locale}) async {
    try {
      _logger.i('📱 이미지 선택 시작');
      emit(OcrImageSelecting());

      // 현재 언어 설정 가져오기 (기본값: 한국어)
      final currentLocale = locale ?? AppLocale.korea;

      // 권한 확인
      final hasPermission = await PermissionService.requestGalleryPermission();
      if (!hasPermission) {
        emit(
          OcrError(AppStrings.getGalleryPermissionRequired(currentLocale)),
        );
        return;
      }

      // 이미지 선택 (image_picker 사용)
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        final imageFile = File(image.path);
        _logger.i('🖼️ 이미지 선택됨: ${imageFile.path}');
        await processImage(imageFile, locale: currentLocale);
      } else {
        _logger.i('❌ 이미지 선택 취소됨');
        emit(OcrInitial());
      }
    } catch (e) {
      _logger.e('❌ 이미지 선택 중 오류 발생: $e');
      final currentLocale = locale ?? AppLocale.korea;
      emit(OcrError('${AppStrings.getImageSelectError(currentLocale)}: $e'));
    }
  }

  // 이미지 OCR 처리
  Future<void> processImage(File imageFile, {AppLocale? locale}) async {
    // 현재 언어 설정 가져오기 (기본값: 한국어)
    final currentLocale = locale ?? AppLocale.korea;

    try {
      _logger.i('🔍 OCR 처리 시작');
      emit(OcrProcessing(imageFile));

      final localeObj = _getLocaleFromAppLocale(currentLocale);

      // 자동 언어 감지 사용 (더 정확함)
      String recognizedText;
      try {
        recognizedText = await _ocrService.recognizeText(imageFile, localeObj);
      } catch (e) {
        // 특정 언어 인식 실패 시 자동 감지 사용
        recognizedText = await _ocrService.recognizeTextAuto(imageFile);
      }

      if (recognizedText.trim().isEmpty) {
        emit(OcrError(AppStrings.getOcrFailedMessage(currentLocale)));
        return;
      }

      _logger.i('✅ 텍스트 인식 완료: ${recognizedText.length}자');

      // OCR 결과 생성 (파싱 없음)
      final ocrResult = _receiptParserService.createOcrResultFromText(
        recognizedText,
        imagePath: imageFile.path,
      );

      _logger.i('🎉 OCR 결과 생성 완료');
      emit(OcrResultGenerated(ocrResult: ocrResult, imageFile: imageFile));

      // OCR 완료 후 자동으로 Gemini 분석 시작
      _logger.i('🤖 자동 Gemini 분석 시작');
      await startGeminiAnalysis(locale: currentLocale);
    } catch (e) {
      _logger.e('❌ OCR 처리 중 오류 발생: $e');
      emit(OcrError('${AppStrings.getOcrProcessingError(currentLocale)}: $e'));
    }
  }

  /// Gemini로 OCR 텍스트 분석 시작 (수동 호출)
  Future<void> startGeminiAnalysis({AppLocale? locale}) async {
    try {
      final currentState = state;
      final currentLocale = locale ?? AppLocale.korea;

      if (currentState is! OcrResultGenerated) {
        _logger.e('❌ OCR 결과가 생성되지 않은 상태에서 Gemini 분석을 시작할 수 없습니다.');
        emit(OcrError(AppStrings.getOcrResultNotGenerated(currentLocale)));
        return;
      }

      _logger.i('🤖 Gemini 분석 시작');
      emit(
        OcrGeminiAnalyzing(
          ocrResult: currentState.ocrResult,
          imageFile: currentState.imageFile,
        ),
      );

      // Gemini로 OCR 텍스트 분석
      final geminiResult = await _ocrGeminiService.processOcrTextForIngredients(
        currentState.ocrResult.originalText,
      );

      if (geminiResult['success'] == true) {
        _logger.i('✅ Gemini 분석 완료: ${geminiResult['total_extracted']}개 재료 추출');
        emit(
          OcrGeminiCompleted(
            ocrResult: currentState.ocrResult,
            imageFile: currentState.imageFile,
            geminiResult: geminiResult,
          ),
        );
      } else {
        _logger.e('❌ Gemini 분석 실패: ${geminiResult['error']}');
        final errorMessage = geminiResult['error'] ?? '';
        emit(OcrError(
            '${AppStrings.getGeminiAnalysisError(currentLocale)}: $errorMessage'));
      }
    } catch (e) {
      _logger.e('❌ Gemini 분석 중 오류 발생: $e');
      final currentLocale = locale ?? AppLocale.korea;
      emit(OcrError('${AppStrings.getGeminiAnalysisError(currentLocale)}: $e'));
    }
  }

  // 상태 초기화
  void reset() {
    _logger.i('🔄 OCR 상태 초기화');
    emit(OcrInitial());
  }

  // AppLocale을 Locale으로 변환
  Locale _getLocaleFromAppLocale(AppLocale appLocale) {
    switch (appLocale) {
      case AppLocale.korea:
        return const Locale('ko', 'KR');
      case AppLocale.japan:
        return const Locale('ja', 'JP');
      case AppLocale.china:
        return const Locale('zh', 'CN');
      case AppLocale.usa:
        return const Locale('en', 'US');
      case AppLocale.chinaTraditional:
        return const Locale('zh', 'TW');
      case AppLocale.vietnam:
        return const Locale('vi', 'VN');
    }
  }
}
