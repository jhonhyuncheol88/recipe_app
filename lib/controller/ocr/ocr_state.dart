import 'package:equatable/equatable.dart';
import '../../model/index.dart';

// OCR 상태 기본 클래스
abstract class OcrState extends Equatable {
  const OcrState();

  @override
  List<Object?> get props => [];
}

// 초기 상태
class OcrInitial extends OcrState {
  const OcrInitial();
}

// 로딩 상태
class OcrLoading extends OcrState {
  const OcrLoading();
}

// 카메라 준비 상태
class OcrCameraReady extends OcrState {
  const OcrCameraReady();
}

// 이미지 처리 중
class OcrProcessingImage extends OcrState {
  final String imagePath;

  const OcrProcessingImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// OCR 결과 로드 성공
class OcrResultLoaded extends OcrState {
  final OcrResult ocrResult;
  final List<ScannedItem> scannedItems;
  final String originalText;

  const OcrResultLoaded({
    required this.ocrResult,
    required this.scannedItems,
    required this.originalText,
  });

  @override
  List<Object?> get props => [ocrResult, scannedItems, originalText];
}

// 스캔된 아이템 수정 성공
class ScannedItemUpdated extends OcrState {
  final ScannedItem updatedItem;
  final List<ScannedItem> scannedItems;

  const ScannedItemUpdated({
    required this.updatedItem,
    required this.scannedItems,
  });

  @override
  List<Object?> get props => [updatedItem, scannedItems];
}

// 스캔된 아이템 삭제 성공
class ScannedItemRemoved extends OcrState {
  final String removedItemId;
  final List<ScannedItem> scannedItems;

  const ScannedItemRemoved({
    required this.removedItemId,
    required this.scannedItems,
  });

  @override
  List<Object?> get props => [removedItemId, scannedItems];
}

// 스캔된 아이템 추가 성공
class ScannedItemAdded extends OcrState {
  final ScannedItem addedItem;
  final List<ScannedItem> scannedItems;

  const ScannedItemAdded({
    required this.addedItem,
    required this.scannedItems,
  });

  @override
  List<Object?> get props => [addedItem, scannedItems];
}

// OCR 결과 저장 성공
class OcrResultSaved extends OcrState {
  final OcrResult ocrResult;

  const OcrResultSaved(this.ocrResult);

  @override
  List<Object?> get props => [ocrResult];
}

// OCR 결과를 재료로 변환 성공
class OcrConvertedToIngredients extends OcrState {
  final List<ScannedItem> scannedItems;
  final int convertedCount;

  const OcrConvertedToIngredients({
    required this.scannedItems,
    required this.convertedCount,
  });

  @override
  List<Object?> get props => [scannedItems, convertedCount];
}

// OCR 스캔 취소됨
class OcrScanCancelled extends OcrState {
  const OcrScanCancelled();
}

// OCR 스캔 재시도
class OcrScanRetrying extends OcrState {
  const OcrScanRetrying();
}

// OCR 설정 업데이트 성공
class OcrSettingsUpdated extends OcrState {
  final Map<String, dynamic> settings;

  const OcrSettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

// OCR 히스토리 로드 성공
class OcrHistoryLoaded extends OcrState {
  final List<OcrResult> history;

  const OcrHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

// OCR 히스토리 삭제 성공
class OcrHistoryDeleted extends OcrState {
  final String deletedOcrResultId;

  const OcrHistoryDeleted(this.deletedOcrResultId);

  @override
  List<Object?> get props => [deletedOcrResultId];
}

// OCR 검증 상태
class OcrValidationState extends OcrState {
  final List<ScannedItem> validItems;
  final List<ScannedItem> invalidItems;
  final double confidence;

  const OcrValidationState({
    required this.validItems,
    required this.invalidItems,
    required this.confidence,
  });

  @override
  List<Object?> get props => [validItems, invalidItems, confidence];
}

// 에러 상태
class OcrError extends OcrState {
  final String message;
  final String? errorCode;

  const OcrError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// 빈 상태 (OCR 결과가 없을 때)
class OcrEmpty extends OcrState {
  const OcrEmpty();
} 