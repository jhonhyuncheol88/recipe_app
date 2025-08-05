import 'package:equatable/equatable.dart';
import '../../model/index.dart';

// OCR 이벤트 기본 클래스
abstract class OcrEvent extends Equatable {
  const OcrEvent();

  @override
  List<Object?> get props => [];
}

// OCR 스캔 시작
class StartOcrScan extends OcrEvent {
  const StartOcrScan();
}

// 이미지에서 텍스트 추출
class ExtractTextFromImage extends OcrEvent {
  final String imagePath;

  const ExtractTextFromImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// OCR 결과 처리
class ProcessOcrResult extends OcrEvent {
  final String originalText;
  final List<ScannedItem> scannedItems;

  const ProcessOcrResult({
    required this.originalText,
    required this.scannedItems,
  });

  @override
  List<Object?> get props => [originalText, scannedItems];
}

// 스캔된 아이템 수정
class UpdateScannedItem extends OcrEvent {
  final String itemId;
  final ScannedItem updatedItem;

  const UpdateScannedItem({required this.itemId, required this.updatedItem});

  @override
  List<Object?> get props => [itemId, updatedItem];
}

// 스캔된 아이템 삭제
class RemoveScannedItem extends OcrEvent {
  final String itemId;

  const RemoveScannedItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

// 스캔된 아이템 추가
class AddScannedItem extends OcrEvent {
  final ScannedItem item;

  const AddScannedItem(this.item);

  @override
  List<Object?> get props => [item];
}

// OCR 결과 저장
class SaveOcrResult extends OcrEvent {
  final OcrResult ocrResult;

  const SaveOcrResult(this.ocrResult);

  @override
  List<Object?> get props => [ocrResult];
}

// OCR 결과를 재료로 변환
class ConvertOcrToIngredients extends OcrEvent {
  final List<ScannedItem> scannedItems;

  const ConvertOcrToIngredients(this.scannedItems);

  @override
  List<Object?> get props => [scannedItems];
}

// OCR 스캔 취소
class CancelOcrScan extends OcrEvent {
  const CancelOcrScan();
}

// OCR 스캔 재시도
class RetryOcrScan extends OcrEvent {
  const RetryOcrScan();
}

// OCR 설정 변경
class UpdateOcrSettings extends OcrEvent {
  final Map<String, dynamic> settings;

  const UpdateOcrSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

// OCR 히스토리 로드
class LoadOcrHistory extends OcrEvent {
  const LoadOcrHistory();
}

// OCR 히스토리 삭제
class DeleteOcrHistory extends OcrEvent {
  final String ocrResultId;

  const DeleteOcrHistory(this.ocrResultId);

  @override
  List<Object?> get props => [ocrResultId];
}
