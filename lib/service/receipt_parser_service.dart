import '../model/ocr_result.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

class ReceiptParserService {
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

  // OCR 결과를 단순하게 반환 (파싱하지 않음)
  OcrResult createOcrResultFromText(String text, {String? imagePath}) {
    _logger.i('🚀 OCR 결과 생성 (파싱 없음)');

    // OCR 텍스트 후처리하여 구조 개선
    final processedText = _improveOcrStructure(text);

    return OcrResult(
      id: _uuid.v4(),
      originalText: processedText,
      scannedItems: [], // 빈 리스트 (파싱하지 않음)
      scannedAt: DateTime.now(),
      imagePath: imagePath,
    );
  }

  /// OCR 텍스트 구조 개선 - 가격 정보 연결 및 라인 정리
  String _improveOcrStructure(String rawText) {
    try {
      final lines = rawText.split('\n');
      final improvedLines = <String>[];

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // 이미 파이프(|)로 구분된 라인은 그대로 사용
        if (line.contains('|')) {
          improvedLines.add(line);
          continue;
        }

        // 가격 정보가 포함된 라인인지 확인
        if (_containsPriceInfo(line)) {
          // 다음 라인에 가격이 있는지 확인
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1].trim();
            if (_isPriceOnly(nextLine)) {
              // 재료명과 가격을 연결
              improvedLines.add('$line | $nextLine');
              i++; // 다음 라인은 이미 처리했으므로 건너뛰기
              continue;
            }
          }

          // 현재 라인에 가격이 포함된 경우
          improvedLines.add(line);
        } else {
          // 일반 텍스트 라인
          improvedLines.add(line);
        }
      }

      _logger.i(
        '🔧 OCR 구조 개선 완료: ${lines.length} → ${improvedLines.length} 라인',
      );
      return improvedLines.join('\n');
    } catch (e) {
      _logger.e('❌ OCR 구조 개선 중 오류: $e');
      return rawText; // 오류 시 원본 반환
    }
  }

  /// 라인에 가격 정보가 포함되어 있는지 확인
  bool _containsPriceInfo(String line) {
    // 숫자와 쉼표가 포함된 경우
    if (RegExp(r'[\d,]').hasMatch(line)) {
      // 하지만 숫자만 있는 라인은 제외
      if (RegExp(r'^[\d,\s]+$').hasMatch(line)) {
        return false;
      }
      return true;
    }
    return false;
  }

  /// 라인이 가격 정보만 포함하고 있는지 확인
  bool _isPriceOnly(String line) {
    if (line.isEmpty) return false;

    // 숫자, 쉼표, 소수점, 음수 기호만 포함
    if (RegExp(r'^[\d,.\s-]+$').hasMatch(line)) {
      // 쉼표와 공백 제거 후 숫자로 변환 가능한지 확인
      final cleanText = line.replaceAll(',', '').replaceAll(' ', '');
      if (double.tryParse(cleanText) != null) {
        return true;
      }
    }

    // 통화 기호가 포함된 경우
    if (line.contains('원') || line.contains('₩') || line.contains('\$')) {
      return true;
    }

    return false;
  }
}
