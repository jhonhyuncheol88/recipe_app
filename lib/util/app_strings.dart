import 'app_strings/app_strings_base.dart';
import 'app_strings/app_strings_ingredient.dart';
import 'app_strings/app_strings_recipe.dart';
import 'app_strings/app_strings_sauce.dart';
import 'app_strings/app_strings_ocr.dart';
import 'app_strings/app_strings_ai.dart';
import 'app_strings/app_strings_auth.dart';
import 'app_strings/app_strings_settings.dart';
import 'app_strings/app_strings_common.dart';
import 'app_strings/app_strings_onboarding.dart';
import 'app_strings/app_strings_ad.dart';

import 'app_locale.dart';

/// 국가별 언어 대응을 위한 문자열 관리
///
/// 모든 문자열 메서드는 카테고리별로 분리된 mixin 파일에서 관리됩니다.
/// - app_strings_base.dart: 기본 앱 정보
/// - app_strings_ingredient.dart: 재료 관련
/// - app_strings_recipe.dart: 레시피 관련
/// - app_strings_sauce.dart: 소스 관련
/// - app_strings_ocr.dart: OCR 관련
/// - app_strings_ai.dart: AI 관련
/// - app_strings_auth.dart: 인증 관련
/// - app_strings_settings.dart: 설정 관련
/// - app_strings_common.dart: 공통 메서드
/// - app_strings_onboarding.dart: 온보딩 관련
/// - app_strings_ad.dart: 광고 관련
class AppStrings {
  static String getAccount(AppLocale locale) =>
      AppStringsAuth.getAccount(locale);
  static String getAccountInfo(AppLocale locale) =>
      AppStringsAuth.getAccountInfo(locale);
  static String getAccountSettings(AppLocale locale) =>
      AppStringsAuth.getAccountSettings(locale);
  static String getAppVersion(AppLocale locale) =>
      AppStringsCommon.getAppVersion(locale);
  static String getDeveloperInfo(AppLocale locale) =>
      AppStringsCommon.getDeveloperInfo(locale);
  static String getAdLoadFailed(AppLocale locale) =>
      AppStringsAd.getAdLoadFailed(locale);
  static String getAdd(AppLocale locale) => AppStringsSauce.getAdd(locale);
  static String getAddAllIngredientsAtOnce(AppLocale locale) =>
      AppStringsAi.getAddAllIngredientsAtOnce(locale);
  static String getAddIngredient(AppLocale locale) =>
      AppStringsIngredient.getAddIngredient(locale);
  static String getAddIngredientButton(AppLocale locale) =>
      AppStringsIngredient.getAddIngredientButton(locale);
  static String getAddIngredientRequired(AppLocale locale) =>
      AppStringsAi.getAddIngredientRequired(locale);
  static String getAddIngredientToList(AppLocale locale) =>
      AppStringsIngredient.getAddIngredientToList(locale);
  static String getAddIngredientToSauce(AppLocale locale) =>
      AppStringsSauce.getAddIngredientToSauce(locale);
  static String getAddRecipe(AppLocale locale) =>
      AppStringsRecipe.getAddRecipe(locale);
  static String getAddRecipeButton(AppLocale locale) =>
      AppStringsRecipe.getAddRecipeButton(locale);
  static String getAddSauce(AppLocale locale) =>
      AppStringsIngredient.getAddSauce(locale);
  static String getAddSauceButton(AppLocale locale) =>
      AppStringsIngredient.getAddSauceButton(locale);
  static String getAdditionalIngredientsNeeded(AppLocale locale) =>
      AppStringsAi.getAdditionalIngredientsNeeded(locale);
  static String getAi(AppLocale locale) => AppStringsAi.getAi(locale);
  static String getAiRecipeCookingInstructions(AppLocale locale) =>
      AppStringsIngredient.getAiRecipeCookingInstructions(locale);
  static String getAiRecipeCostInfo(AppLocale locale) =>
      AppStringsCommon.getAiRecipeCostInfo(locale);
  static String getAiRecipeDeleted(AppLocale locale) =>
      AppStringsAi.getAiRecipeDeleted(locale);
  static String getAiRecipeDetail(AppLocale locale) =>
      AppStringsAi.getAiRecipeDetail(locale);
  static String getAiRecipeDialogDescription(AppLocale locale) =>
      AppStringsAi.getAiRecipeDialogDescription(locale);
  static String getAiRecipeDialogMessage(AppLocale locale) =>
      AppStringsAi.getAiRecipeDialogMessage(locale);
  static String getAiRecipeDialogTitle(AppLocale locale) =>
      AppStringsAi.getAiRecipeDialogTitle(locale);
  static String getAiRecipeGeneration(AppLocale locale) =>
      AppStringsAi.getAiRecipeGeneration(locale);
  static String getAiRecipeGenerationButton(AppLocale locale) =>
      AppStringsAi.getAiRecipeGenerationButton(locale);
  static String getAiRecipeGenerationDescription(AppLocale locale) =>
      AppStringsAi.getAiRecipeGenerationDescription(locale);
  static String getAiRecipeGenerationTab(AppLocale locale) =>
      AppStringsAi.getAiRecipeGenerationTab(locale);
  static String getAiRecipeGenerationTitle(AppLocale locale) =>
      AppStringsAi.getAiRecipeGenerationTitle(locale);
  static String getAiRecipeGeneratorInstructions(AppLocale locale) =>
      AppStringsAi.getAiRecipeGeneratorInstructions(locale);
  static String getAiRecipeGeneratorUsage(AppLocale locale) =>
      AppStringsAi.getAiRecipeGeneratorUsage(locale);
  static String getAiRecipeList(AppLocale locale) =>
      AppStringsAi.getAiRecipeList(locale);
  static String getAiRecipeManagement(AppLocale locale) =>
      AppStringsAi.getAiRecipeManagement(locale);
  static String getAiRecipeNotFound(AppLocale locale) =>
      AppStringsAi.getAiRecipeNotFound(locale);
  static String getAiRecipeSaved(AppLocale locale) =>
      AppStringsAi.getAiRecipeSaved(locale);
  static String getAiRecipeStandard(AppLocale locale) =>
      AppStringsAi.getAiRecipeStandard(locale);
  static String getAiRecipeStats(AppLocale locale) =>
      AppStringsAi.getAiRecipeStats(locale);
  static String getAiRecipeTotalCost(AppLocale locale) =>
      AppStringsRecipe.getAiRecipeTotalCost(locale);
  static String getAiSalesAnalysis(AppLocale locale) =>
      AppStringsAi.getAiSalesAnalysis(locale);
  static String getAiSalesAnalysisDescription(AppLocale locale) =>
      AppStringsAi.getAiSalesAnalysisDescription(locale);
  static String getAiSalesAnalysisDialogTitle(AppLocale locale) =>
      AppStringsAi.getAiSalesAnalysisDialogTitle(locale);
  static String getAiSalesAnalysisDialogMessage(AppLocale locale) =>
      AppStringsAi.getAiSalesAnalysisDialogMessage(locale);
  static String getAiSalesAnalysisDialogDescription(AppLocale locale) =>
      AppStringsAi.getAiSalesAnalysisDialogDescription(locale);
  static String getAiSalesAnalysisTitle(AppLocale locale) =>
      AppStringsAi.getAiSalesAnalysisTitle(locale);
  static String getAlarmTimeSetting(AppLocale locale) =>
      AppStringsCommon.getAlarmTimeSetting(locale);
  static String getAll(AppLocale locale) => AppStringsCommon.getAll(locale);
  static String getAllowPermission(AppLocale locale) =>
      AppStringsOnboarding.getAllowPermission(locale);
  static String getAllowed(AppLocale locale) =>
      AppStringsOnboarding.getAllowed(locale);
  static String getAmount(AppLocale locale) =>
      AppStringsIngredient.getAmount(locale);
  static String getAmountRequired(AppLocale locale) =>
      AppStringsIngredient.getAmountRequired(locale);
  static String getAnalysisFailed(AppLocale locale) =>
      AppStringsAi.getAnalysisFailed(locale);
  static String getAnalysisFailedMessage(AppLocale locale) =>
      AppStringsAi.getAnalysisFailedMessage(locale);
  static String getAnalysisResultNotFound(AppLocale locale) =>
      AppStringsAi.getAnalysisResultNotFound(locale);
  static String getAnalysisError(AppLocale locale) =>
      AppStringsAi.getAnalysisError(locale);
  static String getAnalyzeWithAi(AppLocale locale) =>
      AppStringsAi.getAnalyzeWithAi(locale);
  static String getAnalyzing(AppLocale locale) =>
      AppStringsAi.getAnalyzing(locale);
  static String getAppDescription(AppLocale locale) =>
      AppStringsCommon.getAppDescription(locale);
  static String getAppSettings(AppLocale locale) =>
      AppStringsSettings.getAppSettings(locale);
  static String getAppTitle(AppLocale locale) =>
      AppStringsBase.getAppTitle(locale);
  static String getBackToHome(AppLocale locale) =>
      AppStringsCommon.getBackToHome(locale);
  static String getBasicInfo(AppLocale locale) =>
      AppStringsRecipe.getBasicInfo(locale);
  static String getBasicInformation(AppLocale locale) =>
      AppStringsIngredient.getBasicInformation(locale);
  static String getBeginnerLevel(AppLocale locale) =>
      AppStringsIngredient.getBeginnerLevel(locale);
  static String getBulkAdd(AppLocale locale) =>
      AppStringsIngredient.getBulkAdd(locale);
  static String getBulkAddIngredients(AppLocale locale) =>
      AppStringsIngredient.getBulkAddIngredients(locale);
  static String getBulkAddIngredientsDescription(AppLocale locale) =>
      AppStringsIngredient.getBulkAddIngredientsDescription(locale);
  static String getBulkAddTooltip(AppLocale locale) =>
      AppStringsIngredient.getBulkAddTooltip(locale);
  static String getBulkIngredientAdditionError(AppLocale locale) =>
      AppStringsCommon.getBulkIngredientAdditionError(locale);
  static String getBulkIngredientAdditionFeature(AppLocale locale) =>
      AppStringsAi.getBulkIngredientAdditionFeature(locale);
  static String getBulkSave(AppLocale locale) =>
      AppStringsIngredient.getBulkSave(locale);
  static String getBulkSaveFailed(AppLocale locale) =>
      AppStringsIngredient.getBulkSaveFailed(locale);
  static String getBulkSaveSuccess(AppLocale locale) =>
      AppStringsIngredient.getBulkSaveSuccess(locale);
  static String getBusinessInsights(AppLocale locale) =>
      AppStringsAi.getBusinessInsights(locale);
  static String getCalculatedCost(AppLocale locale) =>
      AppStringsCommon.getCalculatedCost(locale);
  static String getCameraPermissionAlreadyGranted(AppLocale locale) =>
      AppStringsOnboarding.getCameraPermissionAlreadyGranted(locale);
  static String getCameraPermissionDenied(AppLocale locale) =>
      AppStringsOnboarding.getCameraPermissionDenied(locale);
  static String getCameraPermissionDescription(AppLocale locale) =>
      AppStringsOnboarding.getCameraPermissionDescription(locale);
  static String getCameraPermissionGranted(AppLocale locale) =>
      AppStringsOnboarding.getCameraPermissionGranted(locale);
  static String getCameraPermissionPermanentlyDenied(AppLocale locale) =>
      AppStringsOnboarding.getCameraPermissionPermanentlyDenied(locale);
  static String getCameraPermissionTitle(AppLocale locale) =>
      AppStringsOnboarding.getCameraPermissionTitle(locale);
  static String getCancel(AppLocale locale) =>
      AppStringsCommon.getCancel(locale);
  static String getCopied(AppLocale locale) =>
      AppStringsCommon.getCopied(locale);
  static String getCancelSelection(AppLocale locale) =>
      AppStringsCommon.getCancelSelection(locale);
  static String getCannotLoadIngredients(AppLocale locale) =>
      AppStringsAi.getCannotLoadIngredients(locale);
  static String getChangeLaterInfo(AppLocale locale) =>
      AppStringsOnboarding.getChangeLaterInfo(locale);
  static String getClose(AppLocale locale) => AppStringsAi.getClose(locale);
  static String getCompetitiveAdvantages(AppLocale locale) =>
      AppStringsAi.getCompetitiveAdvantages(locale);
  static String getConfirm(AppLocale locale) =>
      AppStringsCommon.getConfirm(locale);
  static String getConfirmAndSave(AppLocale locale) =>
      AppStringsOcr.getConfirmAndSave(locale);
  static String getPrivacyPolicy(AppLocale locale) =>
      AppStringsCommon.getPrivacyPolicy(locale);
  static String getPrivacyPolicyDescription(AppLocale locale) =>
      AppStringsCommon.getPrivacyPolicyDescription(locale);
  static String getTermsOfService(AppLocale locale) =>
      AppStringsCommon.getTermsOfService(locale);
  static String getTermsOfServiceDescription(AppLocale locale) =>
      AppStringsCommon.getTermsOfServiceDescription(locale);
  static String getConversionFailed(AppLocale locale) =>
      AppStringsAi.getConversionFailed(locale);
  static String getConversionRate(AppLocale locale) =>
      AppStringsAi.getConversionRate(locale);
  static String getConversionSuccess(AppLocale locale) =>
      AppStringsAi.getConversionSuccess(locale);
  static String getConvertToRecipe(AppLocale locale) =>
      AppStringsAi.getConvertToRecipe(locale);
  static String getConvertToRecipeDescription(AppLocale locale) =>
      AppStringsAi.getConvertToRecipeDescription(locale);
  static String getConverted(AppLocale locale) =>
      AppStringsAi.getConverted(locale);
  static String getConvertedRecipes(AppLocale locale) =>
      AppStringsAi.getConvertedRecipes(locale);
  static String getCookingInstructions(AppLocale locale) =>
      AppStringsAi.getCookingInstructions(locale);
  static String getCookingStyle(AppLocale locale) =>
      AppStringsAi.getCookingStyle(locale);
  static String getCookingTime(AppLocale locale) =>
      AppStringsAi.getCookingTime(locale);
  static String getCorrectData(AppLocale locale) =>
      AppStringsOcr.getCorrectData(locale);
  static String getCost(AppLocale locale) => AppStringsCommon.getCost(locale);
  static String getCostEfficiency(AppLocale locale) =>
      AppStringsAi.getCostEfficiency(locale);
  static String getCostInfo(AppLocale locale) =>
      AppStringsAi.getCostInfo(locale);
  static String getCostPerServing(AppLocale locale) =>
      AppStringsCommon.getCostPerServing(locale);
  static String getCount(AppLocale locale) => AppStringsCommon.getCount(locale);
  static String getCreate(AppLocale locale) =>
      AppStringsSauce.getCreate(locale);
  static String getCreateDifferentStyleRecipes(AppLocale locale) =>
      AppStringsCommon.getCreateDifferentStyleRecipes(locale);
  static String getCreateDifferentStyleRecipesDescription(AppLocale locale) =>
      AppStringsCommon.getCreateDifferentStyleRecipesDescription(locale);
  static String getCurrentPlan(AppLocale locale) =>
      AppStringsAuth.getCurrentPlan(locale);
  static String getDaily(AppLocale locale) =>
      AppStringsSettings.getDaily(locale);
  static String getDataReset(AppLocale locale) =>
      AppStringsCommon.getDataReset(locale);
  static String getDataResetSuccess(AppLocale locale) =>
      AppStringsCommon.getDataResetSuccess(locale);
  static String getDataResetWarning(AppLocale locale) =>
      AppStringsCommon.getDataResetWarning(locale);
  static String getDataValidationError(AppLocale locale) =>
      AppStringsIngredient.getDataValidationError(locale);
  static String getDatabaseFile(AppLocale locale) =>
      AppStringsSettings.getDatabaseFile(locale);
  static String getDatabaseFileOnly(AppLocale locale) =>
      AppStringsSettings.getDatabaseFileOnly(locale);
  static String getDaysAgo(AppLocale locale, int days) =>
      AppStringsCommon.getDaysAgo(locale, days);
  static String getDelete(AppLocale locale) =>
      AppStringsCommon.getDelete(locale);
  static String getDeleteAiRecipe(AppLocale locale) =>
      AppStringsAi.getDeleteAiRecipe(locale);
  static String getDeleteAiRecipeConfirm(AppLocale locale) =>
      AppStringsAi.getDeleteAiRecipeConfirm(locale);
  static String getDeleteError(AppLocale locale, String error) =>
      AppStringsCommon.getDeleteError(locale, error);
  static String getDeleteRecipe(AppLocale locale) =>
      AppStringsRecipe.getDeleteRecipe(locale);
  static String getDeleteRecipeConfirm(AppLocale locale) =>
      AppStringsRecipe.getDeleteRecipeConfirm(locale);
  static String getDeleteSelected(AppLocale locale) =>
      AppStringsCommon.getDeleteSelected(locale);
  static String getSelectedCount(AppLocale locale, int count) =>
      AppStringsCommon.getSelectedCount(locale, count);
  static String getDeleteSelectedRecipes(AppLocale locale) =>
      AppStringsRecipe.getDeleteSelectedRecipes(locale);
  static String getDeleteSelectedRecipesConfirm(AppLocale locale, int count) =>
      AppStringsRecipe.getDeleteSelectedRecipesConfirm(locale, count);
  static String getDenied(AppLocale locale) =>
      AppStringsOnboarding.getDenied(locale);
  static String getDeveloperTeam(AppLocale locale) =>
      AppStringsCommon.getDeveloperTeam(locale);
  static String getDifficulty(AppLocale locale) =>
      AppStringsAi.getDifficulty(locale);
  static String getDocumentsFolder(AppLocale locale) =>
      AppStringsSettings.getDocumentsFolder(locale);
  static String getDownloadFolder(AppLocale locale) =>
      AppStringsSettings.getDownloadFolder(locale);
  static String getDownloadTemplate(AppLocale locale) =>
      AppStringsIngredient.getDownloadTemplate(locale);
  static String getDuplicateIngredientName(AppLocale locale) =>
      AppStringsIngredient.getDuplicateIngredientName(locale);
  static String getEdit(AppLocale locale) => AppStringsCommon.getEdit(locale);
  static String getEditIngredient(AppLocale locale) =>
      AppStringsIngredient.getEditIngredient(locale);
  static String getEditIngredientAmount(AppLocale locale) =>
      AppStringsIngredient.getEditIngredientAmount(locale);
  static String getEditIngredientInfo(AppLocale locale) =>
      AppStringsOcr.getEditIngredientInfo(locale);
  static String getEditRecipe(AppLocale locale) =>
      AppStringsRecipe.getEditRecipe(locale);
  static String getEditSauceAmount(AppLocale locale) =>
      AppStringsIngredient.getEditSauceAmount(locale);
  static String getEnableNotifications(AppLocale locale) =>
      AppStringsSettings.getEnableNotifications(locale);
  static String getEnableNotificationsDescription(AppLocale locale) =>
      AppStringsSettings.getEnableNotificationsDescription(locale);
  static String getEnterAmount(AppLocale locale) =>
      AppStringsIngredient.getEnterAmount(locale);
  static String getEnterAmountHint(AppLocale locale) =>
      AppStringsIngredient.getEnterAmountHint(locale);
  static String getEnterIngredientName(AppLocale locale) =>
      AppStringsIngredient.getEnterIngredientName(locale);
  static String getEnterIngredientNameHint(AppLocale locale) =>
      AppStringsIngredient.getEnterIngredientNameHint(locale);
  static String getEnterPrice(AppLocale locale) =>
      AppStringsIngredient.getEnterPrice(locale);
  static String getEnterPriceHint(AppLocale locale) =>
      AppStringsIngredient.getEnterPriceHint(locale);
  static String getEnterSauceName(AppLocale locale) =>
      AppStringsSauce.getEnterSauceName(locale);
  static String getErrorOccurred(AppLocale locale) =>
      AppStringsCommon.getErrorOccurred(locale);
  static String getExpiryDanger(AppLocale locale) =>
      AppStringsCommon.getExpiryDanger(locale);
  static String getExpiryDangerDescription(AppLocale locale) =>
      AppStringsSettings.getExpiryDangerDescription(locale);
  static String getExpiryDangerNotification(AppLocale locale) =>
      AppStringsSettings.getExpiryDangerNotification(locale);
  static String getExpiryDate(AppLocale locale) =>
      AppStringsIngredient.getExpiryDate(locale);
  static String getNoExpiryDate(AppLocale locale) =>
      AppStringsIngredient.getNoExpiryDate(locale);
  static String getExpired(AppLocale locale) =>
      AppStringsIngredient.getExpired(locale);
  static String getDanger(AppLocale locale) =>
      AppStringsIngredient.getDanger(locale);
  static String getWarning(AppLocale locale) =>
      AppStringsIngredient.getWarning(locale);
  static String getNormal(AppLocale locale) =>
      AppStringsIngredient.getNormal(locale);
  static String getExpiryDateDescription(AppLocale locale) =>
      AppStringsIngredient.getExpiryDateDescription(locale);
  static String getExpiryExpired(AppLocale locale) =>
      AppStringsCommon.getExpiryExpired(locale);
  static String getExpiryExpiredDescription(AppLocale locale) =>
      AppStringsSettings.getExpiryExpiredDescription(locale);
  static String getExpiryExpiredNotification(AppLocale locale) =>
      AppStringsSettings.getExpiryExpiredNotification(locale);
  static String getExpiryNotificationBenefit(AppLocale locale) =>
      AppStringsOnboarding.getExpiryNotificationBenefit(locale);
  static String getExpiryWarning(AppLocale locale) =>
      AppStringsCommon.getExpiryWarning(locale);
  static String getExpiryWarningDescription(AppLocale locale) =>
      AppStringsSettings.getExpiryWarningDescription(locale);
  static String getExpiryWarningNotification(AppLocale locale) =>
      AppStringsSettings.getExpiryWarningNotification(locale);
  static String getExportComplete(AppLocale locale) =>
      AppStringsSettings.getExportComplete(locale);
  static String getExportCompleteMessage(AppLocale locale, String location) =>
      AppStringsSettings.getExportCompleteMessage(locale, location);
  static String getExportData(AppLocale locale) =>
      AppStringsSettings.getExportData(locale);
  static String getExportDataDescription(AppLocale locale) =>
      AppStringsSettings.getExportDataDescription(locale);
  static String getExportFailed(AppLocale locale) =>
      AppStringsSettings.getExportFailed(locale);
  static String getExportFailedMessage(AppLocale locale, String error) =>
      AppStringsSettings.getExportFailedMessage(locale, error);
  static String getExportToCsv(AppLocale locale) =>
      AppStringsIngredient.getExportToCsv(locale);
  static String getFeatureComingSoon(AppLocale locale, String featureName) =>
      AppStringsAi.getFeatureComingSoon(locale, featureName);
  static String getFeatureInProgress(AppLocale locale, String featureName) =>
      AppStringsCommon.getFeatureInProgress(locale, featureName);
  static String getFileReadError(AppLocale locale) =>
      AppStringsIngredient.getFileReadError(locale);
  static String getFilterByCuisine(AppLocale locale) =>
      AppStringsAi.getFilterByCuisine(locale);
  static String getFreeUser(AppLocale locale) =>
      AppStringsAuth.getFreeUser(locale);
  static String getFreeUserFeatures(AppLocale locale) =>
      AppStringsAuth.getFreeUserFeatures(locale);
  static String getFusion(AppLocale locale) =>
      AppStringsCommon.getFusion(locale);
  static String getFusionStyle(AppLocale locale) =>
      AppStringsCommon.getFusionStyle(locale);
  static String getFusionStyleRecipeDialogDescription(AppLocale locale) =>
      AppStringsAi.getFusionStyleRecipeDialogDescription(locale);
  static String getGalleryPermissionDescription(AppLocale locale) =>
      AppStringsOnboarding.getGalleryPermissionDescription(locale);
  static String getGalleryPermissionRequired(AppLocale locale) =>
      AppStringsOcr.getGalleryPermissionRequired(locale);
  static String getGalleryPermissionTitle(AppLocale locale) =>
      AppStringsOnboarding.getGalleryPermissionTitle(locale);
  static String getGeminiAnalysisError(AppLocale locale) =>
      AppStringsAi.getGeminiAnalysisError(locale);
  static String getGeneratedRecipe(AppLocale locale) =>
      AppStringsAi.getGeneratedRecipe(locale);
  static String getGeneratingRecipe(AppLocale locale) =>
      AppStringsAi.getGeneratingRecipe(locale);
  static String getGoogleAccountLogin(AppLocale locale) =>
      AppStringsAuth.getGoogleAccountLogin(locale);
  static String getGoogleLoginButton(AppLocale locale) =>
      AppStringsAuth.getGoogleLoginButton(locale);
  static String getHomeSubtitle(AppLocale locale) =>
      AppStringsAuth.getHomeSubtitle(locale);
  static String getImageSelectError(AppLocale locale) =>
      AppStringsOcr.getImageSelectError(locale);
  static String getImportComplete(AppLocale locale) =>
      AppStringsSettings.getImportComplete(locale);
  static String getImportData(AppLocale locale) =>
      AppStringsSettings.getImportData(locale);
  static String getImportDataDescription(AppLocale locale) =>
      AppStringsSettings.getImportDataDescription(locale);
  static String getImportFailed(AppLocale locale) =>
      AppStringsSettings.getImportFailed(locale);
  static String getImportFailedMessage(AppLocale locale, String error) =>
      AppStringsSettings.getImportFailedMessage(locale, error);
  static String getImportFromCsv(AppLocale locale) =>
      AppStringsIngredient.getImportFromCsv(locale);
  static String getImportantUpdatesBenefit(AppLocale locale) =>
      AppStringsOnboarding.getImportantUpdatesBenefit(locale);
  static String getIngredientAddFailed(AppLocale locale) =>
      AppStringsIngredient.getIngredientAddFailed(locale);
  static String getIngredientAddedSuccessfully(AppLocale locale) =>
      AppStringsIngredient.getIngredientAddedSuccessfully(locale);
  static String getIngredientAdditionFeature(AppLocale locale) =>
      AppStringsAi.getIngredientAdditionFeature(locale);
  static String getIngredientAvailability(AppLocale locale) =>
      AppStringsAi.getIngredientAvailability(locale);
  static String getIngredientCostLabel(AppLocale locale) =>
      AppStringsCommon.getIngredientCostLabel(locale);
  static String getIngredientCount(AppLocale locale, int count) =>
      AppStringsIngredient.getIngredientCount(locale, count);
  static String getIngredientCountSimple(AppLocale locale) =>
      AppStringsIngredient.getIngredientCountSimple(locale);
  static String getIngredientDeleted(AppLocale locale) =>
      AppStringsRecipe.getIngredientDeleted(locale);
  static String getIngredientFallback(AppLocale locale) =>
      AppStringsCommon.getIngredientFallback(locale);
  static String getIngredientInfo(AppLocale locale) =>
      AppStringsIngredient.getIngredientInfo(locale);
  static String getIngredientList(AppLocale locale) =>
      AppStringsIngredient.getIngredientList(locale);
  static String getIngredientManagement(AppLocale locale) =>
      AppStringsCommon.getIngredientManagement(locale);
  static String getIngredientName(AppLocale locale) =>
      AppStringsIngredient.getIngredientName(locale);
  static String getIngredientNameRequired(AppLocale locale) =>
      AppStringsIngredient.getIngredientNameRequired(locale);
  static String getIngredientPhotosBenefit(AppLocale locale) =>
      AppStringsOnboarding.getIngredientPhotosBenefit(locale);
  static String getIngredientTagFresh(AppLocale locale) =>
      AppStringsIngredient.getIngredientTagFresh(locale);
  static String getIngredientTagFrozen(AppLocale locale) =>
      AppStringsIngredient.getIngredientTagFrozen(locale);
  static String getIngredientTagIndoor(AppLocale locale) =>
      AppStringsIngredient.getIngredientTagIndoor(locale);
  static String getIngredientUpdateFailed(AppLocale locale) =>
      AppStringsRecipe.getIngredientUpdateFailed(locale);
  static String getIngredientUpdatedSuccessfully(AppLocale locale) =>
      AppStringsRecipe.getIngredientUpdatedSuccessfully(locale);
  static String getIngredients(AppLocale locale) =>
      AppStringsIngredient.getIngredients(locale);
  static String getIngredientsAnalysis(AppLocale locale) =>
      AppStringsAi.getIngredientsAnalysis(locale);
  static String getIngredientsAndAmounts(AppLocale locale) =>
      AppStringsRecipe.getIngredientsAndAmounts(locale);
  static String getIngredientsSaved(AppLocale locale) =>
      AppStringsOcr.getIngredientsSaved(locale);
  static String getIngredientsToBeSaved(AppLocale locale, int count) =>
      AppStringsSettings.getIngredientsToBeSaved(locale, count);
  static String getInputAmount(AppLocale locale) =>
      AppStringsCommon.getInputAmount(locale);
  static String getInvalidFileFormat(AppLocale locale) =>
      AppStringsIngredient.getInvalidFileFormat(locale);
  static String getItemsWithoutPrice(AppLocale locale) =>
      AppStringsOcr.getItemsWithoutPrice(locale);
  static String getJoinDate(AppLocale locale) =>
      AppStringsAuth.getJoinDate(locale);
  static String getKoreanCuisine(AppLocale locale) =>
      AppStringsIngredient.getKoreanCuisine(locale);
  static String getKoreanStyle(AppLocale locale) =>
      AppStringsCommon.getKoreanStyle(locale);
  static String getKoreanStyleRecipeDialogDescription(AppLocale locale) =>
      AppStringsAi.getKoreanStyleRecipeDialogDescription(locale);
  static String getLanguageSelection(AppLocale locale) =>
      AppStringsCommon.getLanguageSelection(locale);
  static String getLanguageSettings(AppLocale locale) =>
      AppStringsSettings.getLanguageSettings(locale);
  static String getLoadingAiRecipe(AppLocale locale) =>
      AppStringsAi.getLoadingAiRecipe(locale);
  static String getLoginComplete(AppLocale locale) =>
      AppStringsAuth.getLoginComplete(locale);
  static String getLoginFailure(AppLocale locale) =>
      AppStringsAuth.getLoginFailure(locale);
  static String getLoginFailureMessage(AppLocale locale) =>
      AppStringsAuth.getLoginFailureMessage(locale);
  static String getLoginRequired(AppLocale locale) =>
      AppStringsSettings.getLoginRequired(locale);
  static String getLoginSubtitle(AppLocale locale) =>
      AppStringsAuth.getLoginSubtitle(locale);
  static String getLoginTitle(AppLocale locale) =>
      AppStringsAuth.getLoginTitle(locale);
  static String getLogout(AppLocale locale) => AppStringsAuth.getLogout(locale);
  static String getMarketingPoints(AppLocale locale) =>
      AppStringsAi.getMarketingPoints(locale);
  static String getMinutes(AppLocale locale) =>
      AppStringsIngredient.getMinutes(locale);
  static String getMonthDay(AppLocale locale, int month, int day) =>
      AppStringsCommon.getMonthDay(locale, month, day);
  static String getMonthly(AppLocale locale) =>
      AppStringsSettings.getMonthly(locale);
  static String getMultiplier(AppLocale locale) =>
      AppStringsRecipe.getMultiplier(locale);
  static String getMultiplierDescription(AppLocale locale) =>
      AppStringsRecipe.getMultiplierDescription(locale);
  static String getMultiplierRange(AppLocale locale) =>
      AppStringsRecipe.getMultiplierRange(locale);
  static String getNetworkError(AppLocale locale) =>
      AppStringsCommon.getNetworkError(locale);
  static String getNoIngredients(AppLocale locale) =>
      AppStringsIngredient.getNoIngredients(locale);
  static String getNoIngredientsDescription(AppLocale locale) =>
      AppStringsIngredient.getNoIngredientsDescription(locale);
  static String getNoIngredientsForRecipe(AppLocale locale) =>
      AppStringsAi.getNoIngredientsForRecipe(locale);
  static String getNoIngredientsFound(AppLocale locale) =>
      AppStringsOcr.getNoIngredientsFound(locale);
  static String getNoIngredientsSelected(AppLocale locale) =>
      AppStringsRecipe.getNoIngredientsSelected(locale);
  static String getNoMemo(AppLocale locale) =>
      AppStringsRecipe.getNoMemo(locale);
  static String getNoPriceData(AppLocale locale) =>
      AppStringsSettings.getNoPriceData(locale);
  static String getNoRecipeIngredients(AppLocale locale) =>
      AppStringsRecipe.getNoRecipeIngredients(locale);
  static String getNoRecipeSauces(AppLocale locale) =>
      AppStringsIngredient.getNoRecipeSauces(locale);
  static String getNoRecipes(AppLocale locale) =>
      AppStringsRecipe.getNoRecipes(locale);
  static String getNoRecipesDescription(AppLocale locale) =>
      AppStringsRecipe.getNoRecipesDescription(locale);
  static String getNoRegisteredIngredients(AppLocale locale) =>
      AppStringsAi.getNoRegisteredIngredients(locale);
  static String getNoSauceIngredients(AppLocale locale) =>
      AppStringsSauce.getNoSauceIngredients(locale);
  static String getNoSauces(AppLocale locale) =>
      AppStringsSauce.getNoSauces(locale);
  static String getNoSavedAiRecipes(AppLocale locale) =>
      AppStringsAi.getNoSavedAiRecipes(locale);
  static String getNoSavedAiRecipesDescription(AppLocale locale) =>
      AppStringsAi.getNoSavedAiRecipesDescription(locale);
  static String getNotSignedIn(AppLocale locale) =>
      AppStringsAuth.getNotSignedIn(locale);
  static String getNotificationPermissionDescription(AppLocale locale) =>
      AppStringsOnboarding.getNotificationPermissionDescription(locale);
  static String getNotificationPermissionTitle(AppLocale locale) =>
      AppStringsOnboarding.getNotificationPermissionTitle(locale);
  static String getNotificationSettings(AppLocale locale) =>
      AppStringsSettings.getNotificationSettings(locale);
  static String getOcrCompleted(AppLocale locale) =>
      AppStringsOcr.getOcrCompleted(locale);
  static String getOcrFailed(AppLocale locale) =>
      AppStringsOcr.getOcrFailed(locale);
  static String getOcrFailedMessage(AppLocale locale) =>
      AppStringsOcr.getOcrFailedMessage(locale);
  static String getOcrMainTitle(AppLocale locale) =>
      AppStringsOcr.getOcrMainTitle(locale);
  static String getOcrProcessing(AppLocale locale) =>
      AppStringsOcr.getOcrProcessing(locale);
  static String getOcrProcessingError(AppLocale locale) =>
      AppStringsOcr.getOcrProcessingError(locale);
  static String getOcrResultNotGenerated(AppLocale locale) =>
      AppStringsOcr.getOcrResultNotGenerated(locale);
  static String getOnboarding(AppLocale locale) =>
      AppStringsSettings.getOnboarding(locale);
  static String getOnboardingAdNoticeDescription(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingAdNoticeDescription(locale);
  static String getOnboardingAdNoticeFooter(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingAdNoticeFooter(locale);
  static String getOnboardingAdNoticePoint(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingAdNoticePoint(locale);
  static String getOnboardingAdNoticeTitle(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingAdNoticeTitle(locale);
  static String getOnboardingAfter(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingAfter(locale);
  static String getOnboardingAiRecipe(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingAiRecipe(locale);
  static String getOnboardingAiRecipeSubtitle(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingAiRecipeSubtitle(locale);
  static String getOnboardingBefore(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingBefore(locale);
  static String getOnboardingBeforeAfter(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingBeforeAfter(locale);
  static String getOnboardingCostCalculation(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingCostCalculation(locale);
  static String getOnboardingCostCalculationSubtitle(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingCostCalculationSubtitle(locale);
  static String getOnboardingCostExample(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingCostExample(locale);
  static String getOnboardingDescription(AppLocale locale) =>
      AppStringsSettings.getOnboardingDescription(locale);
  static String getOnboardingExample(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingExample(locale);
  static String getOnboardingExpiryExample(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingExpiryExample(locale);
  static String getOnboardingExpiryManagement(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingExpiryManagement(locale);
  static String getOnboardingExpiryManagementSubtitle(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingExpiryManagementSubtitle(locale);
  static String getOnboardingImageScan(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingImageScan(locale);
  static String getOnboardingImageScanSubtitle(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingImageScanSubtitle(locale);
  static String getOnboardingIngredientCategory(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingIngredientCategory(locale);
  static String getOnboardingMainFeatures(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingMainFeatures(locale);
  static String getOnboardingNext(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingNext(locale);
  static String getOnboardingOptionalSettings(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingOptionalSettings(locale);
  static String getOnboardingReady(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingReady(locale);
  static String getOnboardingReadyMessage(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingReadyMessage(locale);
  static String getOnboardingSkip(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingSkip(locale);
  static String getOnboardingStart(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingStart(locale);
  static String getOnboardingSubtitle(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingSubtitle(locale);
  static String getOnboardingTargetCostRatio(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingTargetCostRatio(locale);
  static String getOnboardingUsageExample(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingUsageExample(locale);
  static String getOnboardingWelcome(AppLocale locale) =>
      AppStringsOnboarding.getOnboardingWelcome(locale);
  static String getOpenSettings(AppLocale locale) =>
      AppStringsOcr.getOpenSettings(locale);
  static String getOpeningScript(AppLocale locale) =>
      AppStringsAi.getOpeningScript(locale);
  static String getOptimalPriceAnalysis(AppLocale locale) =>
      AppStringsAi.getOptimalPriceAnalysis(locale);
  static String getOptimalSellingSeason(AppLocale locale) =>
      AppStringsAi.getOptimalSellingSeason(locale);
  static String getOutputAmount(AppLocale locale) =>
      AppStringsRecipe.getOutputAmount(locale);
  static String getOutputAmountHint(AppLocale locale) =>
      AppStringsRecipe.getOutputAmountHint(locale);
  static String getOutputAmountInvalid(AppLocale locale) =>
      AppStringsRecipe.getOutputAmountInvalid(locale);
  static String getOutputAmountRequired(AppLocale locale) =>
      AppStringsRecipe.getOutputAmountRequired(locale);
  static String getOutputUnit(AppLocale locale) =>
      AppStringsRecipe.getOutputUnit(locale);
  static String getOutputUnitRequired(AppLocale locale) =>
      AppStringsRecipe.getOutputUnitRequired(locale);
  static String getPageNotFoundSubtitle(AppLocale locale) =>
      AppStringsCommon.getPageNotFoundSubtitle(locale);
  static String getPageNotFoundTitle(AppLocale locale) =>
      AppStringsCommon.getPageNotFoundTitle(locale);
  static String getParsedIngredients(AppLocale locale) =>
      AppStringsOcr.getParsedIngredients(locale);
  static String getParsingSummary(AppLocale locale) =>
      AppStringsOcr.getParsingSummary(locale);
  static String getPeople(AppLocale locale) =>
      AppStringsIngredient.getPeople(locale);
  static String getPermissionBenefitTitle(AppLocale locale) =>
      AppStringsOnboarding.getPermissionBenefitTitle(locale);
  static String getPermissionDenied(AppLocale locale) =>
      AppStringsOcr.getPermissionDenied(locale);
  static String getPermissionDeniedMessage(AppLocale locale) =>
      AppStringsOnboarding.getPermissionDeniedMessage(locale);
  static String getPermissionDeniedTitle(AppLocale locale) =>
      AppStringsOnboarding.getPermissionDeniedTitle(locale);
  static String getPermissionSetup(AppLocale locale) =>
      AppStringsOnboarding.getPermissionSetup(locale);
  static String getPersonalizedNotificationBenefit(AppLocale locale) =>
      AppStringsOnboarding.getPersonalizedNotificationBenefit(locale);
  static String getPleaseWait(AppLocale locale) =>
      AppStringsSettings.getPleaseWait(locale);
  static String getPremiumUser(AppLocale locale) =>
      AppStringsAuth.getPremiumUser(locale);
  static String getPremiumUserFeatures(AppLocale locale) =>
      AppStringsAuth.getPremiumUserFeatures(locale);
  static String getPreview(AppLocale locale) =>
      AppStringsIngredient.getPreview(locale);
  static String getPreviewDescription(AppLocale locale) =>
      AppStringsIngredient.getPreviewDescription(locale);
  static String getPriceChart(AppLocale locale) =>
      AppStringsSettings.getPriceChart(locale);
  static String getPriceJustification(AppLocale locale) =>
      AppStringsAi.getPriceJustification(locale);
  static String getPriceRequired(AppLocale locale) =>
      AppStringsIngredient.getPriceRequired(locale);
  static String getProfitPerServing(AppLocale locale) =>
      AppStringsAi.getProfitPerServing(locale);
  static String getProfitabilityTips(AppLocale locale) =>
      AppStringsAi.getProfitabilityTips(locale);
  static String getPurchaseAmount(AppLocale locale) =>
      AppStringsIngredient.getPurchaseAmount(locale);
  static String getPurchasePrice(AppLocale locale) =>
      AppStringsIngredient.getPurchasePrice(locale);
  static String getQuantity(AppLocale locale) =>
      AppStringsSettings.getQuantity(locale);
  static String getQuickRegistrationBenefit(AppLocale locale) =>
      AppStringsOnboarding.getQuickRegistrationBenefit(locale);
  static String getReceiptImage(AppLocale locale) =>
      AppStringsSettings.getReceiptImage(locale);
  static String getReceiptOcrBenefit(AppLocale locale) =>
      AppStringsOnboarding.getReceiptOcrBenefit(locale);
  static String getRecentGenerated(AppLocale locale) =>
      AppStringsAi.getRecentGenerated(locale);
  static String getRecipeAddError(AppLocale locale) =>
      AppStringsRecipe.getRecipeAddError(locale);
  static String getRecipeAdded(AppLocale locale) =>
      AppStringsRecipe.getRecipeAdded(locale);
  static String getRecipeDescription(AppLocale locale) =>
      AppStringsAi.getRecipeDescription(locale);
  static String getRecipeDescriptionHint(AppLocale locale) =>
      AppStringsRecipe.getRecipeDescriptionHint(locale);
  static String getRecipeDescriptionScript(AppLocale locale) =>
      AppStringsRecipe.getRecipeDescriptionScript(locale);
  static String getRecipeGeneration(AppLocale locale) =>
      AppStringsAi.getRecipeGeneration(locale);
  static String getRecipeGenerationError(AppLocale locale) =>
      AppStringsAi.getRecipeGenerationError(locale);
  static String getRecipeIngredients(AppLocale locale) =>
      AppStringsRecipe.getRecipeIngredients(locale);
  static String getRecipeIngredientsRequired(AppLocale locale) =>
      AppStringsIngredient.getRecipeIngredientsRequired(locale);
  static String getRecipeManagement(AppLocale locale) =>
      AppStringsCommon.getRecipeManagement(locale);
  static String getRecipeMemo(AppLocale locale) =>
      AppStringsRecipe.getRecipeMemo(locale);
  static String getRecipeName(AppLocale locale) =>
      AppStringsRecipe.getRecipeName(locale);
  static String getRecipeNotFound(AppLocale locale) =>
      AppStringsRecipe.getRecipeNotFound(locale);
  static String getRecipeNameNotFound(AppLocale locale) =>
      AppStringsRecipe.getRecipeNameNotFound(locale);
  static String getRecipeNameHint(AppLocale locale) =>
      AppStringsRecipe.getRecipeNameHint(locale);
  static String getRecipeNameRequired(AppLocale locale) =>
      AppStringsRecipe.getRecipeNameRequired(locale);
  static String getRecipeShareCopied(AppLocale locale) =>
      AppStringsOnboarding.getRecipeShareCopied(locale);
  static String getRecipeTagChinese(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagChinese(locale);
  static String getRecipeTagFusion(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagFusion(locale);
  static String getRecipeTagIndian(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagIndian(locale);
  static String getRecipeTagItalian(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagItalian(locale);
  static String getRecipeTagJapanese(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagJapanese(locale);
  static String getRecipeTagKorean(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagKorean(locale);
  static String getRecipeTagMexican(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagMexican(locale);
  static String getRecipeTagThai(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagThai(locale);
  static String getRecipeTagVietnamese(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagVietnamese(locale);
  static String getRecipeTagWestern(AppLocale locale) =>
      AppStringsRecipe.getRecipeTagWestern(locale);
  static String getRecipeTags(AppLocale locale) =>
      AppStringsRecipe.getRecipeTags(locale);
  static String getRecipeUpdateError(AppLocale locale) =>
      AppStringsRecipe.getRecipeUpdateError(locale);
  static String getRecipeUpdated(AppLocale locale) =>
      AppStringsRecipe.getRecipeUpdated(locale);
  static String getRecipes(AppLocale locale) =>
      AppStringsRecipe.getRecipes(locale);
  static String getRecognizedText(AppLocale locale) =>
      AppStringsOcr.getRecognizedText(locale);
  static String getRecommendedPrice(AppLocale locale) =>
      AppStringsAi.getRecommendedPrice(locale);
  static String getRemoveIngredient(AppLocale locale) =>
      AppStringsIngredient.getRemoveIngredient(locale);
  static String getRequiredFieldMissing(AppLocale locale) =>
      AppStringsIngredient.getRequiredFieldMissing(locale);
  static String getRequiredIngredients(AppLocale locale) =>
      AppStringsAi.getRequiredIngredients(locale);
  static String getReset(AppLocale locale) =>
      AppStringsSettings.getReset(locale);
  static String getResetData(AppLocale locale) =>
      AppStringsSettings.getResetData(locale);
  static String getResetDataDescription(AppLocale locale) =>
      AppStringsSettings.getResetDataDescription(locale);
  static String getResetFailed(AppLocale locale) =>
      AppStringsSettings.getResetFailed(locale);
  static String getResetFailedMessage(AppLocale locale, String error) =>
      AppStringsSettings.getResetFailedMessage(locale, error);
  static String getRetry(AppLocale locale) => AppStringsCommon.getRetry(locale);
  static String getReviewError(AppLocale locale, String error) =>
      AppStringsSettings.getReviewError(locale, error);
  static String getRiskFactors(AppLocale locale) =>
      AppStringsAi.getRiskFactors(locale);
  static String getSauceComposition(AppLocale locale) =>
      AppStringsSauce.getSauceComposition(locale);
  static String getSauceCostLabel(AppLocale locale) =>
      AppStringsCommon.getSauceCostLabel(locale);
  static String getSauceFallback(AppLocale locale) =>
      AppStringsCommon.getSauceFallback(locale);
  static String getSauceManagement(AppLocale locale) =>
      AppStringsSauce.getSauceManagement(locale);
  static String getSauceNameExample(AppLocale locale) =>
      AppStringsSauce.getSauceNameExample(locale);
  static String getSauces(AppLocale locale) =>
      AppStringsSauce.getSauces(locale);
  static String getSave(AppLocale locale) => AppStringsCommon.getSave(locale);
  static String getSaveFailed(AppLocale locale) =>
      AppStringsOcr.getSaveFailed(locale);
  static String getSaveFailedMessage(AppLocale locale) =>
      AppStringsOcr.getSaveFailedMessage(locale);
  static String getSaveIngredients(AppLocale locale) =>
      AppStringsOcr.getSaveIngredients(locale);
  static String getSaveRecipe(AppLocale locale) =>
      AppStringsRecipe.getSaveRecipe(locale);
  static String getSaveToDevice(AppLocale locale) =>
      AppStringsSettings.getSaveToDevice(locale);
  static String getSavedAiRecipes(AppLocale locale) =>
      AppStringsAi.getSavedAiRecipes(locale);
  static String getSaving(AppLocale locale) =>
      AppStringsIngredient.getSaving(locale);
  static String getSavingIngredients(AppLocale locale) =>
      AppStringsSettings.getSavingIngredients(locale);
  static String getScanReceipt(AppLocale locale) =>
      AppStringsOcr.getScanReceipt(locale);
  static String getScanReceiptButton(AppLocale locale) =>
      AppStringsOcr.getScanReceiptButton(locale);
  static String getSearchAiRecipes(AppLocale locale) =>
      AppStringsAi.getSearchAiRecipes(locale);
  static String getSearchAiRecipesHint(AppLocale locale) =>
      AppStringsAi.getSearchAiRecipesHint(locale);
  static String getSearchIngredientHint(AppLocale locale) =>
      AppStringsIngredient.getSearchIngredientHint(locale);
  static String getSearchRecipe(AppLocale locale) =>
      AppStringsRecipe.getSearchRecipe(locale);
  static String getSearchRecipeHint(AppLocale locale) =>
      AppStringsIngredient.getSearchRecipeHint(locale);
  static String formatDate(DateTime date, AppLocale locale) =>
      AppStringsCommon.formatDate(date, locale);
  static String getSelectExpiryDate(AppLocale locale) =>
      AppStringsIngredient.getSelectExpiryDate(locale);
  static String getSelectFile(AppLocale locale) =>
      AppStringsIngredient.getSelectFile(locale);
  static String getSelectIngredient(AppLocale locale) =>
      AppStringsIngredient.getSelectIngredient(locale);
  static String getSelectIngredientsToUse(AppLocale locale) =>
      AppStringsAi.getSelectIngredientsToUse(locale);
  static String getSelectedIngredients(AppLocale locale) =>
      AppStringsAi.getSelectedIngredients(locale);
  static String getSelectReceiptFromGallery(AppLocale locale) =>
      AppStringsOcr.getSelectReceiptFromGallery(locale);
  static String getSelectSauce(AppLocale locale) =>
      AppStringsIngredient.getSelectSauce(locale);
  static String getSelectTagsDescription(AppLocale locale) =>
      AppStringsRecipe.getSelectTagsDescription(locale);
  static String getSendFeedback(AppLocale locale) =>
      AppStringsSettings.getSendFeedback(locale);
  static String getSendFeedbackDescription(AppLocale locale) =>
      AppStringsSettings.getSendFeedbackDescription(locale);
  static String getFeedbackEmailBody(AppLocale locale) =>
      AppStringsSettings.getFeedbackEmailBody(locale);
  static String getFeedbackEmailSubject(AppLocale locale) =>
      AppStringsSettings.getFeedbackEmailSubject(locale);
  static String getMailAppUnavailable(AppLocale locale) =>
      AppStringsSettings.getMailAppUnavailable(locale);
  static String getFeedbackEmailContactMessage(AppLocale locale) =>
      AppStringsSettings.getFeedbackEmailContactMessage(locale);
  static String getServingGuidance(AppLocale locale) =>
      AppStringsAi.getServingGuidance(locale);
  static String getServings(AppLocale locale) =>
      AppStringsAi.getServings(locale);
  static String getSettings(AppLocale locale) =>
      AppStringsRecipe.getSettings(locale);
  static String getShare(AppLocale locale) =>
      AppStringsSettings.getShare(locale);
  static String getShareFailed(AppLocale locale) =>
      AppStringsSettings.getShareFailed(locale);
  static String getShareFailedMessage(AppLocale locale, String error) =>
      AppStringsSettings.getShareFailedMessage(locale, error);
  static String getSignIn(AppLocale locale) => AppStringsAuth.getSignIn(locale);
  static String getSignOut(AppLocale locale) =>
      AppStringsAuth.getSignOut(locale);
  static String getSignedInAs(AppLocale locale) =>
      AppStringsAuth.getSignedInAs(locale);
  static String getSkipForNow(AppLocale locale) =>
      AppStringsOnboarding.getSkipForNow(locale);
  static String getSpecialRequest(AppLocale locale) =>
      AppStringsAi.getSpecialRequest(locale);
  static String getSpecialRequestHint(AppLocale locale) =>
      AppStringsAi.getSpecialRequestHint(locale);
  static String getStartAnalysis(AppLocale locale) =>
      AppStringsAi.getStartAnalysis(locale);
  static String getSubscriptionStatus(AppLocale locale) =>
      AppStringsAuth.getSubscriptionStatus(locale);
  static String getTags(AppLocale locale) =>
      AppStringsIngredient.getTags(locale);
  static String getTargetCustomers(AppLocale locale) =>
      AppStringsAi.getTargetCustomers(locale);
  static String getTargetMarginRate(AppLocale locale) =>
      AppStringsAi.getTargetMarginRate(locale);
  static String getTemplateDescription(AppLocale locale) =>
      AppStringsIngredient.getTemplateDescription(locale);
  static String getTipClearPhoto(AppLocale locale) =>
      AppStringsSettings.getTipClearPhoto(locale);
  static String getTipClearText(AppLocale locale) =>
      AppStringsSettings.getTipClearText(locale);
  static String getTipGoodLighting(AppLocale locale) =>
      AppStringsSettings.getTipGoodLighting(locale);
  static String getTips(AppLocale locale) => AppStringsSettings.getTips(locale);
  static String getToday(AppLocale locale) => AppStringsCommon.getToday(locale);
  static String getTotalCost(AppLocale locale) =>
      AppStringsAi.getTotalCost(locale);
  static String getTotalGenerated(AppLocale locale) =>
      AppStringsAi.getTotalGenerated(locale);
  static String getTotalItems(AppLocale locale) =>
      AppStringsOcr.getTotalItems(locale);
  static String getTotalPrice(AppLocale locale) =>
      AppStringsOcr.getTotalPrice(locale);
  static String getTotalWeight(AppLocale locale) =>
      AppStringsSauce.getTotalWeight(locale);
  static String getTryAgain(AppLocale locale) =>
      AppStringsCommon.getTryAgain(locale);
  static String getTryDifferentImage(AppLocale locale) =>
      AppStringsOcr.getTryDifferentImage(locale);
  static String getUniqueSellingPoints(AppLocale locale) =>
      AppStringsAi.getUniqueSellingPoints(locale);
  static String getUnit(AppLocale locale) => AppStringsCommon.getUnit(locale);
  static String getUnitPiece(AppLocale locale) =>
      AppStringsCommon.getUnitPiece(locale);
  static String getUnitSlice(AppLocale locale) =>
      AppStringsCommon.getUnitSlice(locale);
  static String getUnitNameById(String unitId, AppLocale locale) =>
      AppStringsCommon.getUnitNameById(unitId, locale);
  static String getUnitRequired(AppLocale locale) =>
      AppStringsIngredient.getUnitRequired(locale);
  static String getUpdateIngredient(AppLocale locale) =>
      AppStringsRecipe.getUpdateIngredient(locale);
  static String getUpgradeToPremium(AppLocale locale) =>
      AppStringsAuth.getUpgradeToPremium(locale);
  static String getUploadFile(AppLocale locale) =>
      AppStringsIngredient.getUploadFile(locale);
  static String getUpsellingTips(AppLocale locale) =>
      AppStringsAi.getUpsellingTips(locale);
  static String getUser(AppLocale locale) => AppStringsAuth.getUser(locale);
  static String getUserEmail(AppLocale locale) =>
      AppStringsAuth.getUserEmail(locale);
  static String getUserName(AppLocale locale) =>
      AppStringsAuth.getUserName(locale);
  static String getValidAmountRequired(AppLocale locale) =>
      AppStringsIngredient.getValidAmountRequired(locale);
  static String getValidPriceRequired(AppLocale locale) =>
      AppStringsIngredient.getValidPriceRequired(locale);
  static String getVersion(AppLocale locale) =>
      AppStringsCommon.getVersion(locale);
  static String getViewRecipeQuick(AppLocale locale) =>
      AppStringsRecipe.getViewRecipeQuick(locale);
  static String getViewSavedAiRecipes(AppLocale locale) =>
      AppStringsCommon.getViewSavedAiRecipes(locale);
  static String getViewSavedAiRecipesDescription(AppLocale locale) =>
      AppStringsCommon.getViewSavedAiRecipesDescription(locale);
  static String getViewSavedRecipes(AppLocale locale) =>
      AppStringsCommon.getViewSavedRecipes(locale);
  static String getVolume(AppLocale locale) =>
      AppStringsCommon.getVolume(locale);
  static String getWatchAd(AppLocale locale) => AppStringsAd.getWatchAd(locale);
  static String getWeight(AppLocale locale) =>
      AppStringsCommon.getWeight(locale);
  static String getWelcomeMessage(AppLocale locale) =>
      AppStringsAuth.getWelcomeMessage(locale);
  static String getWriteReview(AppLocale locale) =>
      AppStringsSettings.getWriteReview(locale);
  static String getWriteReviewDescription(AppLocale locale) =>
      AppStringsSettings.getWriteReviewDescription(locale);
  static String getYearly(AppLocale locale) =>
      AppStringsSettings.getYearly(locale);
  static String getYesterday(AppLocale locale) =>
      AppStringsCommon.getYesterday(locale);
}
