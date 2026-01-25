import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/model/ocr_result.dart';
import '../../../controller/ocr/ocr_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../theme/app_text_styles.dart';

import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../service/permission_service.dart';
import '../../widget/app_button.dart' show AppButton, AppButtonType;
import '../../widget/app_card.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppStrings.getOcrMainTitle(locale),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
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
          _buildHeaderSection(context, locale),
          const SizedBox(height: 24),
          _buildMainActionSection(context, locale),
          const SizedBox(height: 24),
          _buildDescriptionSection(context, locale),
          const SizedBox(height: 24),
          _buildTipsSection(context, locale),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 64, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            AppStrings.getOcrMainTitle(locale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionSection(BuildContext context, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        children: [
          AppButton(
            onPressed: () {
              _selectImageFromGallery(context);
            },
            text: AppStrings.getSelectReceiptFromGallery(locale),
            icon: Icons.photo_library,
            type: AppButtonType.primary,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getOcrCompleted(locale),
            style: AppTextStyles.caption
                .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.getParsingSummary(locale),
                style: AppTextStyles.cardTitle.copyWith(
                  color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.4),
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
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.getTips(locale),
                style: AppTextStyles.cardTitle.copyWith(
                  color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
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
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView(BuildContext context, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.getOcrProcessing(locale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getPleaseWait(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _selectImageFromGallery(BuildContext context) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final imageFile = File(image.path);
        if (!mounted) return;
        context.read<OcrCubit>().processImage(imageFile);
      }
    } catch (e) {
      if (e.toString().contains('permission') ||
          e.toString().contains('권한') ||
          e.toString().contains('not authorized')) {
        if (!mounted) return;
        await _showPermissionDialog(context);
      } else {
        if (mounted) {
          _showErrorDialog(
            context,
            '이미지 선택 중 오류가 발생했습니다: $e',
            context.read<LocaleCubit>().state,
          );
        }
      }
    }
  }

  Future<void> _showPermissionDialog(BuildContext context) async {
    final locale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getGalleryPermissionRequired(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(AppStrings.getPermissionDenied(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.getOpenSettings(locale)),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      PermissionService.openAppSettings();
    }
  }

  void _showErrorDialog(
    BuildContext context,
    String message,
    AppLocale locale,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getOcrFailed(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(message, style: TextStyle(color: colorScheme.onSurface)),
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
      ingredients: [],
      imagePath: imageFile.path,
      ocrResult: ocrResult,
    );
  }
}
