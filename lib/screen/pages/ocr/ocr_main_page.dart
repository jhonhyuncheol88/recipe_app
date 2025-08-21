import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/model/ocr_result.dart';
import '../../../controller/ocr/ocr_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../service/permission_service.dart';
import '../../widget/app_button.dart' show AppButton, AppButtonType;
import '../../widget/app_card.dart';

import '../../../model/ingredient.dart';
import '../../../router/router_helper.dart';

class OcrMainPage extends StatefulWidget {
  const OcrMainPage({super.key});

  @override
  State<OcrMainPage> createState() => _OcrMainPageState();
}

class _OcrMainPageState extends State<OcrMainPage> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getOcrMainTitle(locale),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<OcrCubit, OcrState>(
        listener: (context, state) {
          if (state is OcrError) {
            _showErrorDialog(context, state.message, locale);
          } else if (state is OcrResultGenerated) {
            _navigateToResultPage(context, state.ocrResult, state.imageFile);
          }
        },
        builder: (context, state) {
          return _buildBody(context, state, locale);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, OcrState state, AppLocale locale) {
    if (state is OcrProcessing) {
      return _buildProcessingView(context, locale);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더 섹션
          _buildHeaderSection(context, locale),

          const SizedBox(height: 24),

          // 메인 액션 섹션
          _buildMainActionSection(context, locale),

          const SizedBox(height: 24),

          // 설명 섹션
          _buildDescriptionSection(context, locale),

          const SizedBox(height: 24),

          // 팁 섹션
          _buildTipsSection(context, locale),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, AppLocale locale) {
    return AppCard(
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            AppStrings.getOcrMainTitle(locale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getSelectReceiptFromGallery(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionSection(BuildContext context, AppLocale locale) {
    return AppCard(
      child: Column(
        children: [
          AppButton(
            onPressed: () {
              print('🎯 OCR 분석 요청됨 - 이미지 선택 시작');
              _selectImageFromGallery(context);
            },
            text: AppStrings.getSelectReceiptFromGallery(locale),
            icon: Icons.photo_library,
            type: AppButtonType.primary,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getOcrCompleted(locale),
            style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, AppLocale locale) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.getParsingSummary(locale),
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            Icons.text_fields,
            AppStrings.getRecognizedText(locale),
            AppStrings.getOcrCompleted(locale),
            locale,
          ),
          _buildFeatureItem(
            context,
            Icons.inventory_2,
            AppStrings.getParsedIngredients(locale),
            AppStrings.getConfirmAndSave(locale),
            locale,
          ),
          _buildFeatureItem(
            context,
            Icons.save,
            AppStrings.getSaveIngredients(locale),
            AppStrings.getIngredientsSaved(locale),
            locale,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    AppLocale locale,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context, AppLocale locale) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.getTips(locale),
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            context,
            '📱',
            AppStrings.getTipClearPhoto(locale),
            locale,
          ),
          _buildTipItem(
            context,
            '💡',
            AppStrings.getTipGoodLighting(locale),
            locale,
          ),
          _buildTipItem(
            context,
            '🔍',
            AppStrings.getTipClearText(locale),
            locale,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(
    BuildContext context,
    String emoji,
    String text,
    AppLocale locale,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView(BuildContext context, AppLocale locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.getOcrProcessing(locale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getPleaseWait(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _selectImageFromGallery(BuildContext context) async {
    print('📱 _selectImageFromGallery 시작');
    try {
      // 권한 확인
      print('🔐 갤러리 권한 확인 중...');
      final hasPermission = await PermissionService.requestGalleryPermission();
      print('🔐 권한 상태: $hasPermission');

      if (!hasPermission) {
        print('❌ 권한 없음 - 권한 다이얼로그 표시');
        _showPermissionDialog(context);
        return;
      }

      // 이미지 선택
      print('🖼️ 이미지 선택 다이얼로그 표시 중...');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        print('✅ 이미지 선택됨: ${image.path}');
        final imageFile = File(image.path);
        // OCR 처리 시작
        print('🚀 OCR 처리 시작');
        context.read<OcrCubit>().processImage(imageFile);
      } else {
        print('❌ 이미지 선택 취소됨');
      }
    } catch (e) {
      print('❌ 이미지 선택 중 오류: $e');
      if (mounted) {
        _showErrorDialog(
          context,
          '이미지 선택 중 오류가 발생했습니다: $e',
          context.read<LocaleCubit>().state,
        );
      }
    }
  }

  void _showPermissionDialog(BuildContext context) {
    final locale = context.read<LocaleCubit>().state;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getGalleryPermissionRequired(locale)),
        content: Text(AppStrings.getPermissionDenied(locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: Text(AppStrings.getOpenSettings(locale)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(
    BuildContext context,
    String message,
    AppLocale locale,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getOcrFailed(locale)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getConfirm(locale)),
          ),
        ],
      ),
    );
  }

  void _navigateToResultPage(
    BuildContext context,
    OcrResult ocrResult,
    File imageFile,
  ) {
    RouterHelper.goToOcrResult(
      context,
      ingredients: [], // Empty list since we're not parsing
      imagePath: imageFile.path,
      ocrResult: ocrResult, // OCR 결과 전달
    );
  }
}
