import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:uuid/uuid.dart';
import '../../model/index.dart';

import 'ocr_state.dart';

class OcrCubit extends Cubit<OcrState> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final Uuid _uuid = const Uuid();

  OcrCubit() : super(const OcrInitial());

  @override
  Future<void> close() async {
    _textRecognizer.close();
    super.close();
  }

  // OCR 스캔 시작
  Future<void> startOcrScan() async {
    try {
      emit(const OcrCameraReady());
    } catch (e) {
      emit(OcrError('OCR 스캔을 시작할 수 없습니다: $e'));
    }
  }

  // 이미지에서 텍스트 추출
  Future<void> extractTextFromImage(String imagePath) async {
    try {
      emit(OcrProcessingImage(imagePath));

      // 이미지 파일 읽기
      final inputImage = InputImage.fromFilePath(imagePath);

      // 텍스트 인식 수행
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // 추출된 텍스트 블록들을 처리
      final List<ScannedItem> scannedItems = _processRecognizedText(
        recognizedText,
      );
      final String originalText = recognizedText.text;

      // OCR 결과 생성
      final ocrResult = OcrResult(
        id: _uuid.v4(),
        originalText: originalText,
        scannedItems: scannedItems,
        scannedAt: DateTime.now(),
        imagePath: imagePath,
      );

      emit(
        OcrResultLoaded(
          ocrResult: ocrResult,
          scannedItems: scannedItems,
          originalText: originalText,
        ),
      );
    } catch (e) {
      emit(OcrError('이미지에서 텍스트를 추출할 수 없습니다: $e'));
    }
  }

  // 인식된 텍스트를 스캔된 아이템으로 변환
  List<ScannedItem> _processRecognizedText(RecognizedText recognizedText) {
    final List<ScannedItem> scannedItems = [];

    for (final TextBlock block in recognizedText.blocks) {
      for (final TextLine line in block.lines) {
        final String text = line.text.trim();
        if (text.isEmpty) continue;

        // 텍스트에서 품목명과 가격을 추출
        final ScannedItem? item = _extractItemFromText(text);
        if (item != null) {
          scannedItems.add(item);
        }
      }
    }

    return scannedItems;
  }

  // 텍스트에서 품목명과 가격 추출
  ScannedItem? _extractItemFromText(String text) {
    // 가격 패턴 찾기 (숫자 + 원/₩)
    final pricePattern = RegExp(r'(\d{1,3}(?:,\d{3})*)\s*(원|₩|원화)?');
    final priceMatch = pricePattern.firstMatch(text);

    if (priceMatch != null) {
      final priceText = priceMatch.group(1)?.replaceAll(',', '') ?? '';
      final price = double.tryParse(priceText);

      if (price != null && price > 0) {
        // 가격을 제외한 부분을 품목명으로 추출
        final itemName = text.replaceAll(priceMatch.group(0)!, '').trim();

        if (itemName.isNotEmpty) {
          return ScannedItem(
            id: _uuid.v4(),
            name: itemName,
            price: price,
            quantity: 1.0, // 기본값
            unit: '개', // 기본값
            isValid: true,
            confidence: 'high',
          );
        }
      }
    }

    return null;
  }

  // 스캔된 아이템 수정
  Future<void> updateScannedItem(String itemId, ScannedItem updatedItem) async {
    try {
      emit(const OcrLoading());

      // 현재 상태에서 스캔된 아이템 목록 가져오기
      final currentState = state;
      if (currentState is OcrResultLoaded) {
        final updatedItems = currentState.scannedItems.map((item) {
          if (item.id == itemId) {
            return updatedItem;
          }
          return item;
        }).toList();

        emit(
          ScannedItemUpdated(
            updatedItem: updatedItem,
            scannedItems: updatedItems,
          ),
        );
      }
    } catch (e) {
      emit(OcrError('아이템 수정에 실패했습니다: $e'));
    }
  }

  // 스캔된 아이템 삭제
  Future<void> removeScannedItem(String itemId) async {
    try {
      emit(const OcrLoading());

      final currentState = state;
      if (currentState is OcrResultLoaded) {
        final updatedItems = currentState.scannedItems
            .where((item) => item.id != itemId)
            .toList();

        emit(
          ScannedItemRemoved(removedItemId: itemId, scannedItems: updatedItems),
        );
      }
    } catch (e) {
      emit(OcrError('아이템 삭제에 실패했습니다: $e'));
    }
  }

  // 스캔된 아이템 추가
  Future<void> addScannedItem(ScannedItem item) async {
    try {
      emit(const OcrLoading());

      final currentState = state;
      if (currentState is OcrResultLoaded) {
        final updatedItems = List<ScannedItem>.from(currentState.scannedItems)
          ..add(item);

        emit(ScannedItemAdded(addedItem: item, scannedItems: updatedItems));
      }
    } catch (e) {
      emit(OcrError('아이템 추가에 실패했습니다: $e'));
    }
  }

  // OCR 결과 저장
  Future<void> saveOcrResult(OcrResult ocrResult) async {
    try {
      emit(const OcrLoading());

      // 여기서 데이터베이스에 저장하는 로직을 추가할 수 있습니다
      // 현재는 메모리에만 저장

      emit(OcrResultSaved(ocrResult));
    } catch (e) {
      emit(OcrError('OCR 결과 저장에 실패했습니다: $e'));
    }
  }

  // OCR 결과를 재료로 변환
  Future<void> convertOcrToIngredients(List<ScannedItem> scannedItems) async {
    try {
      emit(const OcrLoading());

      int convertedCount = 0;
      for (final item in scannedItems) {
        if (item.isValid && item.name.isNotEmpty && item.price > 0) {
          // 여기서 IngredientCubit을 통해 재료를 추가할 수 있습니다
          convertedCount++;
        }
      }

      emit(
        OcrConvertedToIngredients(
          scannedItems: scannedItems,
          convertedCount: convertedCount,
        ),
      );
    } catch (e) {
      emit(OcrError('재료 변환에 실패했습니다: $e'));
    }
  }

  // OCR 스캔 취소
  Future<void> cancelOcrScan() async {
    try {
      emit(const OcrScanCancelled());
    } catch (e) {
      emit(OcrError('OCR 스캔 취소에 실패했습니다: $e'));
    }
  }

  // OCR 스캔 재시도
  Future<void> retryOcrScan() async {
    try {
      emit(const OcrScanRetrying());
    } catch (e) {
      emit(OcrError('OCR 스캔 재시도에 실패했습니다: $e'));
    }
  }

  // OCR 설정 업데이트
  Future<void> updateOcrSettings(Map<String, dynamic> settings) async {
    try {
      emit(const OcrLoading());

      // OCR 설정을 업데이트하는 로직

      emit(OcrSettingsUpdated(settings));
    } catch (e) {
      emit(OcrError('OCR 설정 업데이트에 실패했습니다: $e'));
    }
  }

  // OCR 히스토리 로드
  Future<void> loadOcrHistory() async {
    try {
      emit(const OcrLoading());

      // 여기서 데이터베이스에서 OCR 히스토리를 로드하는 로직을 추가할 수 있습니다
      final List<OcrResult> history = []; // 실제로는 데이터베이스에서 로드

      emit(OcrHistoryLoaded(history));
    } catch (e) {
      emit(OcrError('OCR 히스토리 로드에 실패했습니다: $e'));
    }
  }

  // OCR 히스토리 삭제
  Future<void> deleteOcrHistory(String ocrResultId) async {
    try {
      emit(const OcrLoading());

      // 여기서 데이터베이스에서 OCR 히스토리를 삭제하는 로직을 추가할 수 있습니다

      emit(OcrHistoryDeleted(ocrResultId));
    } catch (e) {
      emit(OcrError('OCR 히스토리 삭제에 실패했습니다: $e'));
    }
  }

  // OCR 결과 검증
  Future<void> validateOcrResult(List<ScannedItem> scannedItems) async {
    try {
      emit(const OcrLoading());

      final List<ScannedItem> validItems = [];
      final List<ScannedItem> invalidItems = [];

      for (final item in scannedItems) {
        if (item.isValid && item.name.isNotEmpty && item.price > 0) {
          validItems.add(item);
        } else {
          invalidItems.add(item);
        }
      }

      final confidence = validItems.isNotEmpty
          ? validItems.length / scannedItems.length
          : 0.0;

      emit(
        OcrValidationState(
          validItems: validItems,
          invalidItems: invalidItems,
          confidence: confidence,
        ),
      );
    } catch (e) {
      emit(OcrError('OCR 결과 검증에 실패했습니다: $e'));
    }
  }
}
