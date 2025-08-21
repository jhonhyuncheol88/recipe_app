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
  }) : _ocrService = ocrService ?? OcrService(),
       _permissionService = permissionService ?? PermissionService(),
       _receiptParserService = receiptParserService ?? ReceiptParserService(),
       _ocrGeminiService = ocrGeminiService ?? OcrGeminiService(),
       super(OcrInitial());

  // 갤러리에서 이미지 선택
  Future<void> selectImageFromGallery() async {
    try {
      _logger.i('📱 이미지 선택 시작');
      emit(OcrImageSelecting());

      // 권한 확인
      final hasPermission = await PermissionService.requestGalleryPermission();
      if (!hasPermission) {
        emit(
          OcrError(AppStrings.getGalleryPermissionRequired(AppLocale.korea)),
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
        await processImage(imageFile);
      } else {
        _logger.i('❌ 이미지 선택 취소됨');
        emit(OcrInitial());
      }
    } catch (e) {
      _logger.e('❌ 이미지 선택 중 오류 발생: $e');
      emit(OcrError('이미지 선택 중 오류가 발생했습니다: $e'));
    }
  }

  // 이미지 OCR 처리
  Future<void> processImage(File imageFile, {AppLocale? locale}) async {
    try {
      _logger.i('🔍 OCR 처리 시작');
      emit(OcrProcessing(imageFile));

      // 현재 언어 설정 가져오기 (기본값: 한국어)
      final currentLocale = locale ?? AppLocale.korea;
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
        emit(OcrError(AppStrings.getOcrFailedMessage(AppLocale.korea)));
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
      await startGeminiAnalysis();
    } catch (e) {
      _logger.e('❌ OCR 처리 중 오류 발생: $e');
      emit(OcrError('OCR 처리 중 오류가 발생했습니다: $e'));
    }
  }

  /// Gemini로 OCR 텍스트 분석 시작 (수동 호출)
  Future<void> startGeminiAnalysis() async {
    try {
      final currentState = state;
      if (currentState is! OcrResultGenerated) {
        _logger.e('❌ OCR 결과가 생성되지 않은 상태에서 Gemini 분석을 시작할 수 없습니다.');
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
        emit(OcrError('Gemini 분석 중 오류가 발생했습니다: ${geminiResult['error']}'));
      }
    } catch (e) {
      _logger.e('❌ Gemini 분석 중 오류 발생: $e');
      emit(OcrError('Gemini 분석 중 오류가 발생했습니다: $e'));
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
      case AppLocale.euro:
        return const Locale('en', 'EU');
      default:
        return const Locale('ko', 'KR');
    }
  }
}
