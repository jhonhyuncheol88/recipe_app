import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';

class OcrService {
  // 다국어 텍스트 인식기 생성 (공식 문서 방식)
  TextRecognizer _getTextRecognizer(Locale locale) {
    try {
      switch (locale.languageCode) {
        case 'ko':
          return TextRecognizer(script: TextRecognitionScript.korean);
        case 'ja':
          return TextRecognizer(script: TextRecognitionScript.japanese);
        case 'zh':
          return TextRecognizer(script: TextRecognitionScript.chinese);
        case 'en':
        default:
          return TextRecognizer(script: TextRecognitionScript.latin);
      }
    } catch (e) {
      // 특정 언어 인식기 생성 실패 시 기본 인식기 사용
      return TextRecognizer();
    }
  }

  // 특정 언어로 텍스트 인식
  Future<String> recognizeText(File imageFile, Locale locale) async {
    try {
      final textRecognizer = _getTextRecognizer(locale);
      final inputImage = InputImage.fromFile(imageFile);

      final recognizedText = await textRecognizer.processImage(inputImage);

      // 리소스 해제
      textRecognizer.close();

      // OCR 결과 후처리하여 영수증 구조 유지
      return _postProcessReceiptText(recognizedText);
    } catch (e) {
      throw Exception('텍스트 인식 실패: $e');
    }
  }

  // 자동 언어 감지 (공식 문서 방식으로 수정)
  Future<String> recognizeTextAuto(File imageFile) async {
    try {
      // 한국어, 일본어, 중국어, 영어 순서로 시도
      final languages = [
        const Locale('ko'),
        const Locale('ja'),
        const Locale('zh'),
        const Locale('en'),
      ];

      for (final locale in languages) {
        try {
          final result = await recognizeText(imageFile, locale);
          if (result.trim().isNotEmpty) {
            return result;
          }
        } catch (e) {
          // 개별 언어 인식 실패 시 계속 진행
          continue;
        }
      }

      throw Exception('모든 언어 인식 시도 실패');
    } catch (e) {
      throw Exception('자동 텍스트 인식 실패: $e');
    }
  }

  /// 영수증 텍스트 후처리 - 구조 유지 및 가격 정보 연결
  String _postProcessReceiptText(RecognizedText recognizedText) {
    try {
      final blocks = recognizedText.blocks;
      final processedLines = <String>[];

      // 각 텍스트 블록을 위치 기반으로 정렬
      final sortedBlocks = blocks.toList()
        ..sort((a, b) {
          // Y 좌표로 먼저 정렬 (위에서 아래로)
          if ((a.boundingBox.top - b.boundingBox.top).abs() > 10) {
            return a.boundingBox.top.compareTo(b.boundingBox.top);
          }
          // Y 좌표가 비슷하면 X 좌표로 정렬 (왼쪽에서 오른쪽으로)
          return a.boundingBox.left.compareTo(b.boundingBox.left);
        });

      // 블록을 라인으로 그룹화
      final lineGroups = <List<TextBlock>>[];
      double? currentY;
      List<TextBlock> currentLine = [];

      for (final block in sortedBlocks) {
        final blockY = block.boundingBox.top;

        // 새로운 라인 시작 (Y 좌표 차이가 10 이상)
        if (currentY == null || (blockY - currentY!).abs() > 10) {
          if (currentLine.isNotEmpty) {
            lineGroups.add(List.from(currentLine));
          }
          currentLine = [block];
          currentY = blockY;
        } else {
          // 같은 라인에 추가
          currentLine.add(block);
        }
      }

      // 마지막 라인 추가
      if (currentLine.isNotEmpty) {
        lineGroups.add(currentLine);
      }

      // 각 라인을 처리하여 재료명과 가격 연결
      for (final line in lineGroups) {
        final lineText = _processLine(line);
        if (lineText.isNotEmpty) {
          processedLines.add(lineText);
        }
      }

      return processedLines.join('\n');
    } catch (e) {
      print('영수증 텍스트 후처리 중 오류: $e');
      // 후처리 실패 시 원본 텍스트 반환
      return recognizedText.text;
    }
  }

  /// 개별 라인 처리 - 재료명과 가격 연결
  String _processLine(List<TextBlock> lineBlocks) {
    if (lineBlocks.isEmpty) return '';

    // 라인 내에서 X 좌표로 정렬 (왼쪽에서 오른쪽으로)
    lineBlocks.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));

    final lineParts = <String>[];

    for (final block in lineBlocks) {
      final text = block.text.trim();
      if (text.isNotEmpty) {
        lineParts.add(text);
      }
    }

    // 라인을 하나로 합치되, 재료명과 가격을 구분
    if (lineParts.length >= 2) {
      // 마지막 부분이 가격인지 확인
      final lastPart = lineParts.last;
      if (_isLikelyPrice(lastPart)) {
        // 재료명과 가격을 구분하여 반환
        final itemName = lineParts.take(lineParts.length - 1).join(' ');
        final price = lastPart;
        return '$itemName | $price';
      }
    }

    // 단일 항목이거나 가격이 아닌 경우
    return lineParts.join(' ');
  }

  /// 텍스트가 가격일 가능성이 높은지 확인
  bool _isLikelyPrice(String text) {
    if (text.isEmpty) return false;

    // 숫자와 쉼표, 소수점만 있는 경우
    if (RegExp(r'^[\d,.\s]+$').hasMatch(text)) {
      // 쉼표 제거 후 숫자로 변환 가능한지 확인
      final cleanText = text.replaceAll(',', '').replaceAll(' ', '');
      if (double.tryParse(cleanText) != null) {
        return true;
      }
    }

    // 음수 가격 (할인)
    if (text.startsWith('-') && RegExp(r'^-[\d,.\s]+$').hasMatch(text)) {
      return true;
    }

    // 통화 기호가 포함된 경우
    if (text.contains('원') || text.contains('₩') || text.contains('\$')) {
      return true;
    }

    return false;
  }

  // 한국어 텍스트 포함 여부 확인
  bool _containsKoreanText(String text) {
    return RegExp(r'[가-힣]').hasMatch(text);
  }

  // 일본어 텍스트 포함 여부 확인
  bool _containsJapaneseText(String text) {
    return RegExp(r'[ぁ-んァ-ン一-龯]').hasMatch(text);
  }

  // 중국어 텍스트 포함 여부 확인
  bool _containsChineseText(String text) {
    return RegExp(r'[\u4e00-\u9fff]').hasMatch(text);
  }
}
