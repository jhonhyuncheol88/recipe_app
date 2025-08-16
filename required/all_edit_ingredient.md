import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_test/core/enums/enums.dart';
import 'package:money_tracker_test/core/styles/apptext_style.dart';
import 'package:money_tracker_test/core/utils/formatting_utils.dart';
import 'package:money_tracker_test/local_model/money_tracker_model/expense_record.dart';
import 'package:money_tracker_test/presentation/controllers/money_tracker/daily/daily_controller.dart';
import 'package:money_tracker_test/presentation/controllers/money_tracker/input/money_tracker_input_controller.dart';
import 'package:money_tracker_test/presentation/controllers/asset/asset_controller.dart';
import 'package:money_tracker_test/main_widget/f_money_tracker_widget/income_expense_select_widget.dart';
import 'package:money_tracker_test/main_widget/wiget_container.dart';
import 'package:money_tracker_test/local_model/asset_model/account.dart';

class AllEditMoneyTrackerWidget extends GetView<DailyController> {
  AllEditMoneyTrackerWidget({Key? key}) : super(key: key);

  // 삭제 대상 아이템 ID를 저장하는 Set - 클래스 레벨에서 선언
  final RxSet<String> itemsToDelete = <String>{}.obs;

  // 수정된 내용 저장하기 - 클래스 메소드로 이동
  Future<void> saveChanges(
    RxMap<String, Map<String, dynamic>> tempEditedRecords,
    RxBool hasChanges,
  ) async {
    try {
      final inputController = Get.find<MoneyTrackerInputController>();
      final controller = Get.find<DailyController>();

      print('=== 일괄 수정 저장 시작 ===');
      print('수정할 항목 수: ${tempEditedRecords.length}');
      print('삭제할 항목 수: ${itemsToDelete.length}');

      // 🔥 개선된 로딩 다이얼로그 - 취소 불가능하고 더 명확한 메시지
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // 뒤로가기 버튼 비활성화
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF81C784)),
                ),
                const SizedBox(height: 16),
                Text(
                  '데이터를 저장하고 있습니다...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '잠시만 기다려주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false, // 바깥 영역 터치로 닫기 비활성화
      );

      int successCount = 0;
      int deleteCount = 0;
      int updateCount = 0;
      int totalChanges = tempEditedRecords.length + itemsToDelete.length;

      print('총 처리할 항목 수: $totalChanges');

      // 🔥 삭제 항목 처리
      print('=== 삭제 항목 처리 시작 ===');
      for (var id in itemsToDelete) {
        try {
          print('삭제 처리 중: $id');
          // DailyController의 deleteExpense 메서드 사용
          await controller.deleteExpense(id);
          deleteCount++;
          successCount++;
          print('삭제 완료: $id');
        } catch (e) {
          print('❌ 삭제 중 오류 발생 ($id): $e');
        }
      }
      print('=== 삭제 항목 처리 완료: ${deleteCount}개 ===');

      // 🔥 수정 항목 처리
      print('=== 수정 항목 처리 시작 ===');
      for (var entry in tempEditedRecords.entries) {
        try {
          // 이미 삭제 예정인 항목은 업데이트하지 않음
          if (itemsToDelete.contains(entry.key)) {
            print('삭제 예정 항목이므로 수정 건너뜀: ${entry.key}');
            continue;
          }

          final recordId = entry.key;
          final changes = entry.value;

          print('수정 처리 중: $recordId');
          print('변경 내용: $changes');

          // 현재 선택된 테이블에 따라 올바른 데이터 소스에서 원본 기록 찾기
          final sourceRecords =
              controller.mainController.selectedTable.value == 'expenses'
                  ? controller.mainController.expenseRecords
                  : controller.mainController.expenseRecords1;

          final record = sourceRecords.firstWhere((e) => e.id == recordId);

          // 변경된 값 또는 원래 값 사용
          final newName = changes['name'] ?? record.name;
          final newMoney = changes['money'] ?? record.money;
          final newContent = changes['content'] ?? record.content;
          final newMerchantName =
              changes['merchantName'] ?? record.merchantName;
          final newTaxType = changes['taxType'] ?? record.taxType;
          final newCreateTime = changes['createTime'] ?? record.createTime;
          final newAccountId = changes['accountId'] ?? record.accountId;

          // 카테고리 이름에 따라 incomeType 결정
          final List<String> incomeCategories = ['현금', '카드', '배달앱', '플랫폼'];
          final bool isIncome = incomeCategories.contains(newName);

          // inputController의 incomeType 설정
          inputController.incomeType.value =
              isIncome ? IncomeType.income : IncomeType.expense;

          // 세금 계산
          double newSupplyPrice = 0;
          double newVatAmount = 0;
          if (newTaxType == taxType.taxable.name) {
            newSupplyPrice = newMoney / 1.1;
            newVatAmount = newMoney - newSupplyPrice;
          }

          // 데이터 업데이트
          await inputController.editExpense(
            record.id,
            newName,
            newMoney,
            newCreateTime.toString(),
            newContent,
            newMerchantName,
            taxTypeStr: newTaxType,
            supplyPrice: newSupplyPrice,
            vatAmount: newVatAmount,
          );

          // 계정 정보 업데이트
          if (newAccountId != null && newAccountId != record.accountId) {
            await controller.updateExpenseAccount(record.id, newAccountId);
            print('계정 정보 업데이트 완료: $newAccountId');
          }

          updateCount++;
          successCount++;
          print('수정 완료: $recordId');
        } catch (e) {
          print('❌ 저장 중 오류 발생 (${entry.key}): $e');
        }
      }
      print('=== 수정 항목 처리 완료: ${updateCount}개 ===');

      // 🔥 데이터 새로고침
      print('=== 데이터 새로고침 시작 ===');
      controller.updateDailyData();
      print('=== 데이터 새로고침 완료 ===');

      // 🔥 상태 초기화
      tempEditedRecords.clear();
      itemsToDelete.clear();
      hasChanges.value = false;

      print('=== 일괄 수정 저장 완료 ===');
      print('성공한 항목 수: $successCount');
      print('수정: ${updateCount}개, 삭제: ${deleteCount}개');

      // 🔥 로딩 다이얼로그 닫기
      Get.back();

      // 🔥 잠시 대기 후 페이지 닫기 (로딩 다이얼로그가 완전히 닫힌 후)
      await Future.delayed(const Duration(milliseconds: 100));
      Get.back(); // 일괄 수정 페이지 닫기

      // 🔥 성공 메시지 표시 (페이지가 닫힌 후)
      await Future.delayed(const Duration(milliseconds: 200));

      String message = '총 ${successCount}개 항목이 성공적으로 처리되었습니다.';
      if (updateCount > 0 && deleteCount > 0) {
        message += '\n(수정: ${updateCount}개, 삭제: ${deleteCount}개)';
      } else if (updateCount > 0) {
        message += '\n(${updateCount}개 항목 수정)';
      } else if (deleteCount > 0) {
        message += '\n(${deleteCount}개 항목 삭제)';
      }

      Get.snackbar(
        '저장 완료',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF81C784).withOpacity(0.1),
        colorText: const Color(0xFF2E7D32),
        borderColor: const Color(0xFF81C784),
        borderWidth: 1,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      print('❌ saveChanges 전체 오류: $e');

      // 오류 발생 시 로딩 다이얼로그 닫기
      try {
        Get.back(); // 로딩 다이얼로그가 열려있다면 닫기
      } catch (dialogError) {
        print('다이얼로그 닫기 중 오류 (무시 가능): $dialogError');
      }

      // 오류 메시지 표시
      Get.snackbar(
        '저장 실패',
        '데이터 저장 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFE57373).withOpacity(0.1),
        colorText: const Color(0xFFD32F2F),
        borderColor: const Color(0xFFE57373),
        borderWidth: 1,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        icon: const Icon(
          Icons.error,
          color: Color(0xFFD32F2F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 페이지 진입 시 데이터 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRepeatExpenses();
    });

    // 데이터 수정을 위한 임시 상태 관리
    final tempEditedRecords = <String, Map<String, dynamic>>{}.obs;
    final hasChanges = false.obs;

    // 날짜 선택 다이얼로그 보여주기
    void showDatePickerDialog(ExpenseRecordItem expense) async {
      final initialDate = expense.createTime;
      final DateTime? picked = await showDatePicker(
        context: Get.context!,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null && picked != initialDate) {
        // 임시 데이터에 새 날짜 저장
        if (!tempEditedRecords.containsKey(expense.id)) {
          tempEditedRecords[expense.id] = {};
        }
        tempEditedRecords[expense.id]!['createTime'] = picked;
        tempEditedRecords.refresh(); // 상태 갱신
        hasChanges.value = true;
      }
    }

    // 카테고리 선택 다이얼로그 보여주기
    void showCategorySelector(ExpenseRecordItem expense) {
      // 현재 항목이 수입인지 지출인지 확인
      final List<String> incomeCategories = ['현금', '카드', '배달앱', '플랫폼'];
      bool isIncome = incomeCategories.contains(expense.name);

      // MoneyTrackerInputController에서 카테고리 목록 가져오기
      final inputController = Get.find<MoneyTrackerInputController>();

      // 현재 incomeType 설정
      if (isIncome) {
        inputController.incomeType.value = IncomeType.income;
      } else {
        inputController.incomeType.value = IncomeType.expense;
      }

      // 현재 선택된 카테고리 설정
      final currentCategory = expense.name;
      if (isIncome) {
        inputController.selectedCategory1.value = currentCategory;
      } else {
        inputController.selectedCategoryE1.value = currentCategory;
      }

      print(
          '바텀시트 표시 시작 - 타입: ${inputController.incomeType.value}, 카테고리: $currentCategory');

      Get.bottomSheet(
        Container(
          height: 500.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: IncomeExpenseSelectWidget(),
        ),
        isScrollControlled: true,
      ).then((_) {
        // 바텀시트가 닫힌 후 상태 확인
        String newCategory = '';
        bool newIsIncome =
            inputController.incomeType.value == IncomeType.income;

        if (newIsIncome) {
          newCategory = inputController.selectedCategory1.value;
        } else {
          newCategory = inputController.selectedCategoryE1.value;
        }

        // 카테고리에 따른 incomeType 다시 확인 - 선택 결과에 상관없이 카테고리 기반으로 결정
        final List<String> incomeCategories = ['현금', '카드', '배달앱', '플랫폼'];
        if (newCategory.isNotEmpty) {
          if (incomeCategories.contains(newCategory)) {
            newIsIncome = true;
            inputController.incomeType.value = IncomeType.income;
          } else {
            newIsIncome = false;
            inputController.incomeType.value = IncomeType.expense;
          }
        }

        String newIncomeType = newIsIncome ? "매출" : "지출";
        print('바텀시트 닫힘 - 카테고리: $newCategory, 타입: $newIncomeType');

        // 현재 편집 중인 카테고리 가져오기 (있으면 편집된 값, 없으면 원래 값)
        final currentEditedCategory =
            tempEditedRecords[expense.id]?['name'] ?? expense.name;

        // 변경사항 체크 - 현재 편집 중인 카테고리와 비교
        bool hasNameChange =
            newCategory.isNotEmpty && newCategory != currentEditedCategory;
        bool hasTypeChange = newIncomeType !=
            (tempEditedRecords[expense.id]?['incomeType'] ??
                expense.incomeType);

        if (hasNameChange || hasTypeChange) {
          // 임시 데이터에 저장
          if (!tempEditedRecords.containsKey(expense.id)) {
            tempEditedRecords[expense.id] = {};
          }

          // 새 카테고리 저장
          if (hasNameChange) {
            tempEditedRecords[expense.id]!['name'] = newCategory;

            // 카테고리가 변경되면 incomeType도 함께 변경
            tempEditedRecords[expense.id]!['incomeType'] = newIncomeType;
          }
          // 새 incomeType 저장 (카테고리 변경에 따른 자동 변경 외에도 직접 변경될 수 있음)
          else if (hasTypeChange) {
            tempEditedRecords[expense.id]!['incomeType'] = newIncomeType;
          }

          tempEditedRecords.refresh(); // 상태 갱신
          hasChanges.value = true;
        }
      });
    }

    // 내용 수정 다이얼로그 보여주기
    void showContentEditor(ExpenseRecordItem expense) {
      final contentController = TextEditingController();
      contentController.text = expense.content ?? '';

      Get.dialog(
        AlertDialog(
          title: Text('내용 수정'),
          content: TextField(
            controller: contentController,
            decoration: InputDecoration(
              hintText: '내용을 입력하세요',
              border: OutlineInputBorder(),
            ),
            maxLines: 1,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (contentController.text != (expense.content ?? '')) {
                  // 임시 데이터에 새 내용 저장
                  if (!tempEditedRecords.containsKey(expense.id)) {
                    tempEditedRecords[expense.id] = {};
                  }
                  tempEditedRecords[expense.id]!['content'] =
                      contentController.text;
                  tempEditedRecords.refresh(); // 상태 갱신
                  hasChanges.value = true;
                }
                Get.back();
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }

    // 거래처 선택 다이얼로그 보여주기
    void showMerchantSelector(ExpenseRecordItem expense) {
      // 거래처 목록 로드
      final merchants = controller.merchantController.merchants;

      Get.dialog(
        AlertDialog(
          title: Text('거래처 선택'),
          content: Container(
            width: double.maxFinite,
            height: 300.h,
            child: ListView.builder(
              itemCount: merchants.length,
              itemBuilder: (context, index) {
                final merchant = merchants[index];
                return ListTile(
                  title: Text(merchant.companyName),
                  // companyName만 표시 (business number나 description은 사용하지 않음)

                  selected: merchant.companyName == expense.merchantName,
                  onTap: () {
                    // 임시 데이터에 새 거래처 저장
                    if (!tempEditedRecords.containsKey(expense.id)) {
                      tempEditedRecords[expense.id] = {};
                    }
                    tempEditedRecords[expense.id]!['merchantName'] =
                        merchant.companyName;
                    tempEditedRecords.refresh(); // 상태 갱신
                    hasChanges.value = true;
                    Get.back();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('취소'),
            ),
            // 직접 입력 버튼 추가
            TextButton(
              onPressed: () {
                Get.back();
                final merchantController = TextEditingController();
                merchantController.text = expense.merchantName ?? '';

                Get.dialog(
                  AlertDialog(
                    title: Text('거래처 직접 입력'),
                    content: TextField(
                      controller: merchantController,
                      decoration: InputDecoration(
                        hintText: '거래처명을 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (merchantController.text !=
                              (expense.merchantName ?? '')) {
                            // 임시 데이터에 새 거래처 저장
                            if (!tempEditedRecords.containsKey(expense.id)) {
                              tempEditedRecords[expense.id] = {};
                            }
                            tempEditedRecords[expense.id]!['merchantName'] =
                                merchantController.text;
                            tempEditedRecords.refresh(); // 상태 갱신
                            hasChanges.value = true;
                          }
                          Get.back();
                        },
                        child: Text('확인'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('직접 입력'),
            ),
          ],
        ),
      );
    }

    // 금액 수정 다이얼로그 보여주기
    void showAmountEditor(ExpenseRecordItem expense) {
      final amountController = TextEditingController();
      // 편집된 금액이 있으면 그 값을 사용, 없으면 원래 금액 사용
      final currentMoney =
          tempEditedRecords[expense.id]?['money'] ?? expense.money;
      amountController.text =
          FormattingUtils.formatNumberWithCommas(currentMoney);

      // 현재 카테고리 가져오기
      final currentCategory =
          tempEditedRecords[expense.id]?['name'] ?? expense.name;
      // 카테고리 기반으로 수입/지출 여부 결정
      final List<String> incomeCategories = ['현금', '카드', '배달앱', '플랫폼'];
      final bool isIncome = incomeCategories.contains(currentCategory);

      // 바텀시트에서 다이얼로그로 변경
      Get.dialog(
        AlertDialog(
          title: Text(
            '금액 수정',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  hintText: '금액을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  prefixText: '₩ ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // 쉼표를 제거한 값
                  String plainValue = value.replaceAll(',', '');

                  // 숫자만 입력되었는지 확인
                  if (plainValue.isNotEmpty &&
                      double.tryParse(plainValue) != null) {
                    // 현재 커서 위치 저장
                    int cursorPosition = amountController.selection.start;

                    // 쉼표 추가 전 텍스트 길이
                    int oldLength = value.length;

                    // 쉼표 포맷팅 적용
                    String formattedValue =
                        FormattingUtils.formatNumberWithCommas(
                            double.parse(plainValue));

                    // 콘트롤러 텍스트 업데이트
                    amountController.text = formattedValue;

                    // 커서 위치 재조정 (쉼표 개수에 따라 달라짐)
                    int newLength = formattedValue.length;
                    int newPosition = cursorPosition + (newLength - oldLength);
                    if (newPosition < 0) newPosition = 0;
                    if (newPosition > formattedValue.length)
                      newPosition = formattedValue.length;

                    amountController.selection = TextSelection.fromPosition(
                      TextPosition(offset: newPosition),
                    );
                  }
                },
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red, // 카테고리에 따라 색상 변경
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 쉼표를 제거하고 숫자 변환
                final double? amount =
                    double.tryParse(amountController.text.replaceAll(',', ''));
                if (amount != null && amount != currentMoney) {
                  // 임시 데이터에 새 금액 저장
                  if (!tempEditedRecords.containsKey(expense.id)) {
                    tempEditedRecords[expense.id] = {};
                  }
                  tempEditedRecords[expense.id]!['money'] = amount;

                  // 수입/지출 여부에 따라 incomeType 업데이트 추가
                  final newIncomeType = isIncome ? "매출" : "지출";
                  if (newIncomeType !=
                      (tempEditedRecords[expense.id]?['incomeType'] ??
                          expense.incomeType)) {
                    tempEditedRecords[expense.id]!['incomeType'] =
                        newIncomeType;
                  }

                  tempEditedRecords.refresh(); // 상태 갱신
                  hasChanges.value = true;
                }
                Get.back();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(Get.context!).primaryColor,
              ),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }

    // 계정 선택 다이얼로그 보여주기
    void showAccountSelector(ExpenseRecordItem expense) {
      _showAccountSelectionBottomSheet(
          context, expense, tempEditedRecords, hasChanges);
    }

    // 과세/면세 상태 전환
    void toggleTaxType(ExpenseRecordItem expense) {
      // 현재 taxType 확인 (편집된 값 우선 사용)
      final currentTaxType =
          tempEditedRecords[expense.id]?['taxType'] ?? expense.taxType;
      final isTaxable = currentTaxType == taxType.taxable.name;

      // 상태 전환
      final newTaxType =
          isTaxable ? taxType.nonTaxable.name : taxType.taxable.name;

      // 임시 데이터에 저장
      if (!tempEditedRecords.containsKey(expense.id)) {
        tempEditedRecords[expense.id] = {};
      }
      tempEditedRecords[expense.id]!['taxType'] = newTaxType;

      // money 값이 있으면 세금 계산 업데이트
      if (tempEditedRecords[expense.id]!.containsKey('money') ||
          newTaxType != expense.taxType) {
        final currentMoney =
            tempEditedRecords[expense.id]?['money'] ?? expense.money;
        double newSupplyPrice = 0;
        double newVatAmount = 0;

        if (newTaxType == taxType.taxable.name) {
          newSupplyPrice = currentMoney / 1.1;
          newVatAmount = currentMoney - newSupplyPrice;
        }

        tempEditedRecords[expense.id]!['supplyPrice'] = newSupplyPrice;
        tempEditedRecords[expense.id]!['vatAmount'] = newVatAmount;
      }

      tempEditedRecords.refresh(); // 상태 갱신
      hasChanges.value = true;
    }

    return Obx(
      () => SafeArea(
        bottom: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: AppText.textSize16(
              context,
              '월별 내역 일괄 수정',
              14,
              FontWeight.w500,
            ),
            centerTitle: true,
            actions: [
              // 삭제 예정 항목 수 표시
              Obx(() => itemsToDelete.isNotEmpty
                  ? Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${itemsToDelete.length}개 삭제 예정',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox()),
              // 저장 버튼 - 변경사항이 있을 때만 활성화
              Obx(() => TextButton(
                    onPressed: hasChanges.value
                        ? () async {
                            await saveChanges(tempEditedRecords, hasChanges);
                          }
                        : null,
                    child: Text(
                      '저장',
                      style: TextStyle(
                        color: hasChanges.value
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ],
          ),
          body: Column(
            children: [
              // 월 선택 헤더
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: ClearContainer(
                  borderRadius: 16.0,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          // 플랫 디자인: boxShadow 제거
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF718096).withAlpha(20)
                                    : const Color(0xFF4A5568).withAlpha(30),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            controller.moveToPreviousMonth();
                          },
                          icon: Icon(
                            CupertinoIcons.back,
                            size: 16.sp,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black87
                                    : Colors.white,
                          ),
                        ),
                      ),
                      AppText.textSize12(
                        context,
                        "${DateFormat('yyyy년 M월').format(DateTime.parse(controller.mainController.dateManager.selectedMonth.value + '-01'))}",
                        16,
                        FontWeight.w600,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          // 플랫 디자인: boxShadow 제거
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF718096).withAlpha(20)
                                    : const Color(0xFF4A5568).withAlpha(30),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            controller.moveToNextMonth();
                          },
                          icon: Icon(
                            CupertinoIcons.forward,
                            size: 16.sp,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black87
                                    : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 컬럼 헤더

              // 거래 목록
              Expanded(
                child: buildExpensesList(
                    context,
                    tempEditedRecords,
                    hasChanges,
                    itemsToDelete,
                    showDatePickerDialog,
                    showCategorySelector,
                    showContentEditor,
                    showMerchantSelector,
                    showAmountEditor,
                    showAccountSelector,
                    toggleTaxType),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpensesList(
    BuildContext context,
    RxMap<String, Map<String, dynamic>> tempEditedRecords,
    RxBool hasChanges,
    RxSet<String> itemsToDelete,
    Function(ExpenseRecordItem) showDatePickerDialog,
    Function(ExpenseRecordItem) showCategorySelector,
    Function(ExpenseRecordItem) showContentEditor,
    Function(ExpenseRecordItem) showMerchantSelector,
    Function(ExpenseRecordItem) showAmountEditor,
    Function(ExpenseRecordItem) showAccountSelector,
    Function(ExpenseRecordItem) toggleTaxType,
  ) {
    return GetBuilder<DailyController>(
      builder: (controller) {
        final sourceRecords =
            controller.mainController.selectedTable.value == 'expenses'
                ? controller.mainController.expenseRecords
                : controller.mainController.expenseRecords1;
        final monthlyExpenses = sourceRecords.where((expense) {
          final expenseDate = DateTime.parse(expense.createTime.toString());
          return DateFormat('yyyy-MM').format(expenseDate) ==
              controller.mainController.dateManager.selectedMonth.value;
        }).toList();

        // 날짜별로 그룹화
        final Map<String, List<ExpenseRecordItem>> dailyExpenses = {};
        for (var expense in monthlyExpenses) {
          final date = expense.createTime.toString().split(' ')[0];
          dailyExpenses[date] ??= [];
          dailyExpenses[date]!.add(expense);
        }

        if (dailyExpenses.isEmpty) {
          return Center(child: Text('이 달에는 거래 내역이 없습니다.'));
        }

        // 날짜 기준으로 정렬
        final sortedDates = dailyExpenses.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: sortedDates.length,
          itemBuilder: (context, dateIndex) {
            final date = sortedDates[dateIndex];
            final expenses = dailyExpenses[date]!;

            // 애니메이션 효과 추가
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 500 + (dateIndex * 100)),
              tween: Tween<double>(begin: 1.0, end: 0.0),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * value), // 아래에서 위로 이동
                  child: Opacity(
                    opacity: 1 - value, // 페이드 인 효과
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: ClearContainer(
                  borderRadius: 20.0,
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 해당 날짜의 거래 목록
                      ...expenses.map(
                        (expense) => _buildExpenseItem(
                            context,
                            expense,
                            tempEditedRecords,
                            hasChanges,
                            itemsToDelete,
                            showDatePickerDialog,
                            showCategorySelector,
                            showContentEditor,
                            showMerchantSelector,
                            showAmountEditor,
                            showAccountSelector,
                            toggleTaxType),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpenseItem(
    BuildContext context,
    ExpenseRecordItem expense,
    RxMap<String, Map<String, dynamic>> tempEditedRecords,
    RxBool hasChanges,
    RxSet<String> itemsToDelete,
    Function(ExpenseRecordItem) showDatePickerDialog,
    Function(ExpenseRecordItem) showCategorySelector,
    Function(ExpenseRecordItem) showContentEditor,
    Function(ExpenseRecordItem) showMerchantSelector,
    Function(ExpenseRecordItem) showAmountEditor,
    Function(ExpenseRecordItem) showAccountSelector,
    Function(ExpenseRecordItem) toggleTaxType,
  ) {
    // Obx 위젯으로 감싸서 tempEditedRecords의 변경에 반응하게 합니다
    return Obx(() {
      // 현재 아이템의 수정된 데이터 가져오기
      final editedData = tempEditedRecords[expense.id] ?? {};

      // 현재 표시할 값 (수정되었다면 수정값, 아니면 원래값)
      final currentTaxType = editedData['taxType'] ?? expense.taxType;
      final currentMoney = editedData['money'] ?? expense.money;
      final currentContent = editedData['content'] ?? expense.content;
      final currentMerchant =
          editedData['merchantName'] ?? expense.merchantName;
      final currentCreateTime = editedData['createTime'] ?? expense.createTime;
      final currentIncomeType = editedData['incomeType'] ?? expense.incomeType;

      // 카테고리 이름 가져오기
      final currentCategory = editedData['name'] ?? expense.name;

      // 카테고리 이름으로 수입/지출 여부 결정
      final List<String> incomeCategories = ['현금', '카드', '배달앱', '플랫폼'];
      bool isIncome = incomeCategories.contains(currentCategory);

      bool isTaxable = currentTaxType == taxType.taxable.name;
      bool isEdited = tempEditedRecords.containsKey(expense.id) &&
          tempEditedRecords[expense.id]!.isNotEmpty;

      // 삭제 예정인지 확인
      bool isMarkedForDeletion = itemsToDelete.contains(expense.id);

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isMarkedForDeletion
              ? const Color(0x81C784).withAlpha(10) // 파스텔 그린 배경 (삭제 예정)
              : isEdited
                  ? const Color(0xFFF176).withAlpha(10) // 파스텔 노랑 배경 (편집됨)
                  : (Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : Colors.grey[800]),
          borderRadius: BorderRadius.circular(12),
          // 플랫 디자인: boxShadow 제거
          border: Border.all(
            color: isMarkedForDeletion
                ? const Color(0x81C784).withAlpha(10)
                : isEdited
                    ? const Color(0xFFF176).withAlpha(10)
                    : (Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF718096).withAlpha(20)
                        : const Color(0xFF4A5568).withAlpha(30)),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // 첫 번째 줄 (날짜, 카테고리, 내용, 거래처)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 날짜 - 클릭 가능한 버튼
                InkWell(
                  onTap: () => showDatePickerDialog(expense),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 55.w,
                    padding:
                        EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC), // Clarity 배경색
                      borderRadius: BorderRadius.circular(4),
                      border: editedData.containsKey('createTime')
                          ? Border.all(
                              color: const Color(0xFF81D4FA),
                              width: 1) // 파스텔 블루
                          : Border.all(
                              color: const Color(0xFF718096).withAlpha(20),
                              width: 1,
                            ),
                    ),
                    child: Text(
                      '${currentCreateTime.day}일',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF2D3748), // 진한 회색
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // 카테고리 - 클릭 가능한 버튼
                InkWell(
                  onTap: () => showCategorySelector(expense),
                  child: Container(
                    width: 75.w,
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC), // Clarity 배경색
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: editedData.containsKey('name')
                            ? const Color(0xFF81D4FA) // 파스텔 블루
                            : const Color(0xFF718096).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            editedData['name'] ?? expense.name,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3748), // 진한 회색
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 12.sp,
                          color: const Color(0xFF718096),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // 내용 버튼
                InkWell(
                  onTap: () => showContentEditor(expense),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 70.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB39DDB).withAlpha(20), // 파스텔 보라색
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF512DA8), // 진한 보라색
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            currentContent?.isNotEmpty == true
                                ? currentContent!
                                : '내용',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF512DA8), // 진한 보라색
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.edit,
                          size: 9.sp,
                          color: const Color(0xFF512DA8).withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // 거래처 버튼
                InkWell(
                  onTap: () => showMerchantSelector(expense),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 70.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBCAAA4).withAlpha(20), // 파스텔 갈색
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF5D4037), // 진한 갈색
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            currentMerchant?.isNotEmpty == true
                                ? currentMerchant!
                                : '거래처',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5D4037), // 진한 갈색
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.business,
                          size: 9.sp,
                          color: const Color(0xFF5D4037).withAlpha(70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h), // 첫 번째 줄과 두 번째 줄 사이 간격

            // 두 번째 줄 (금액, 계정, 과세/면세, 삭제버튼)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 금액 - 클릭 가능한 버튼
                InkWell(
                  onTap: () => showAmountEditor(expense),
                  child: Container(
                    width: 90.w,
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isIncome
                          ? const Color(0xFF81C784).withAlpha(20) // 파스텔 그린
                          : const Color(0xFFE57373).withAlpha(20), // 파스텔 레드
                      borderRadius: BorderRadius.circular(4),
                      border: editedData.containsKey('money')
                          ? Border.all(
                              color: isIncome
                                  ? const Color(0xFF2E7D32) // 진한 그린
                                  : const Color(0xFFD32F2F), // 진한 레드
                              width: 1)
                          : Border.all(
                              color: isIncome
                                  ? const Color(0xFF81C784).withAlpha(50)
                                  : const Color(0xFFE57373).withAlpha(50),
                              width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            FormattingUtils.formatNumberWithCommas(
                                currentMoney),
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isIncome
                                  ? const Color(0xFF2E7D32) // 진한 그린
                                  : const Color(0xFFD32F2F), // 진한 레드
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // 계정 버튼 (두 번째 줄로 이동)
                InkWell(
                  onTap: () => showAccountSelector(expense),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 70.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF81D4FA).withAlpha(20), // 파스텔 블루
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: editedData.containsKey('accountId')
                            ? const Color(0xFF1976D2) // 진한 블루
                            : const Color(0xFF1976D2).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            () {
                              // 🔥 수정된 accountId가 있으면 해당 계정 이름 조회
                              final currentAccountId =
                                  editedData['accountId'] ?? expense.accountId;

                              if (currentAccountId?.isNotEmpty == true) {
                                final account = Get.find<AssetController>()
                                    .getAccountById(currentAccountId!);
                                if (account != null) {
                                  return Get.find<AssetController>()
                                      .translateAccountName(account.name);
                                }
                              }

                              // 🔥 null이거나 빈 값인 경우 "내 현금"으로 표시
                              return '내 현금';
                            }(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1976D2), // 진한 블루
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.account_balance_wallet,
                          size: 9.sp,
                          color: const Color(0xFF1976D2).withAlpha(70),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // 과세/면세 토글 버튼
                InkWell(
                  onTap: () => toggleTaxType(expense),
                  child: Container(
                    width: 55.w,
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isTaxable
                          ? const Color(0xFFF176).withAlpha(20) // 파스텔 노랑
                          : const Color(0xFF81D4FA).withAlpha(20), // 파스텔 파랑
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isTaxable
                            ? const Color(0xFFF57F17) // 진한 노랑
                            : const Color(0xFF1976D2), // 진한 파랑
                        width: 1,
                      ),
                      // 플랫 디자인: boxShadow 제거
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isTaxable ? '과세' : '면세',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isTaxable
                                ? const Color(0xFFF57F17) // 진한 노랑
                                : const Color(0xFF1976D2), // 진한 파랑
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Icon(
                          Icons.swap_horiz,
                          size: 12.sp,
                          color: isTaxable
                              ? const Color(0xFFF57F17).withAlpha(70)
                              : const Color(0xFF1976D2).withAlpha(70),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 3.w),

                // 삭제 버튼 (주석 해제)
                IconButton(
                  onPressed: () {
                    // 삭제 예정인 경우, 삭제 취소
                    if (isMarkedForDeletion) {
                      // 취소 확인 다이얼로그
                      Get.defaultDialog(
                        title: '삭제 취소',
                        middleText: '이 항목의 삭제 표시를 취소하시겠습니까?',
                        textConfirm: '예',
                        textCancel: '아니오',
                        confirmTextColor: Colors.white,
                        cancelTextColor: Colors.black,
                        buttonColor: Colors.blue,
                        onConfirm: () {
                          itemsToDelete.remove(expense.id);
                          hasChanges.value = tempEditedRecords.isNotEmpty ||
                              itemsToDelete.isNotEmpty;
                          Get.back(); // 다이얼로그 닫기
                        },
                      );
                    } else {
                      // 삭제 확인 다이얼로그
                      Get.defaultDialog(
                        title: '삭제 표시',
                        middleText:
                            '이 항목을 삭제 표시하시겠습니까?\n실제 삭제는 상단의 저장 버튼을 눌러야 수행됩니다.',
                        textConfirm: '예',
                        textCancel: '아니오',
                        confirmTextColor: Colors.white,
                        cancelTextColor: Colors.black,
                        onConfirm: () {
                          // 삭제 예정 목록에 추가
                          itemsToDelete.add(expense.id);
                          hasChanges.value = tempEditedRecords.isNotEmpty ||
                              itemsToDelete.isNotEmpty;
                          Get.back(); // 다이얼로그 닫기
                        },
                      );
                    }
                  },
                  icon: Icon(
                    isMarkedForDeletion ? Icons.restore : Icons.delete,
                    size: 16.sp,
                    color: isMarkedForDeletion ? Colors.blue : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // 계정 선택 바텀시트 표시
  void _showAccountSelectionBottomSheet(
    BuildContext context,
    ExpenseRecordItem expense,
    RxMap<String, Map<String, dynamic>> tempEditedRecords,
    RxBool hasChanges,
  ) {
    Get.bottomSheet(
      Container(
        height: 500.h,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F9FC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF718096),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '계정 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      '닫기',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 계정 목록
            Expanded(
              child: FutureBuilder<List<Account>>(
                future: Get.find<MoneyTrackerInputController>()
                    .getAvailableAccounts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF81C784)),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        '계정을 불러오는 중 오류가 발생했습니다.',
                        style: TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  final accounts = snapshot.data ?? [];

                  if (accounts.isEmpty) {
                    return const Center(
                      child: Text(
                        '사용 가능한 계정이 없습니다.',
                        style: TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  // 자산 그룹별로 계정 분류
                  final groupedAccounts = <String, List<Account>>{};
                  for (final account in accounts) {
                    if (!groupedAccounts.containsKey(account.groupId)) {
                      groupedAccounts[account.groupId] = [];
                    }
                    groupedAccounts[account.groupId]!.add(account);
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: groupedAccounts.keys.length,
                    itemBuilder: (context, index) {
                      final groupId = groupedAccounts.keys.elementAt(index);
                      final groupAccounts = groupedAccounts[groupId]!;
                      final groupName = Get.find<AssetController>()
                          .getGroupDisplayName(groupId);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 그룹 헤더
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 4.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF81C784).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF81C784).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              groupName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                          // 그룹 내 계정들
                          ...groupAccounts
                              .map((account) => Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFF718096),
                                        width: 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      title: Text(
                                        Get.find<AssetController>()
                                            .translateAccountName(account.name),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1A202C),
                                        ),
                                      ),
                                      subtitle: Text(
                                        '잔액: ${NumberFormat('#,###').format(account.currentBalance)}원',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF718096),
                                        ),
                                      ),
                                      trailing: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: () {
                                            // 🔥 현재 선택된 계정 ID 확인
                                            final currentAccountId =
                                                tempEditedRecords[expense.id]
                                                        ?['accountId'] ??
                                                    expense.accountId;

                                            // 🔥 null이거나 빈 값인 경우 "내 현금" 계정과 비교
                                            if (currentAccountId?.isEmpty !=
                                                false) {
                                              // "내 현금" 계정인지 확인
                                              return account.name == '내 현금' &&
                                                      account.groupId == 'CASH'
                                                  ? const Color(0xFF81C784)
                                                  : Colors.transparent;
                                            }

                                            // 일반적인 경우
                                            return currentAccountId ==
                                                    account.id
                                                ? const Color(0xFF81C784)
                                                : Colors.transparent;
                                          }(),
                                          border: Border.all(
                                            color: () {
                                              final currentAccountId =
                                                  tempEditedRecords[expense.id]
                                                          ?['accountId'] ??
                                                      expense.accountId;

                                              if (currentAccountId?.isEmpty !=
                                                  false) {
                                                return account.name == '내 현금' &&
                                                        account.groupId ==
                                                            'CASH'
                                                    ? const Color(0xFF81C784)
                                                    : const Color(0xFF718096);
                                              }

                                              return currentAccountId ==
                                                      account.id
                                                  ? const Color(0xFF81C784)
                                                  : const Color(0xFF718096);
                                            }(),
                                            width: 2,
                                          ),
                                        ),
                                        child: () {
                                          final currentAccountId =
                                              tempEditedRecords[expense.id]
                                                      ?['accountId'] ??
                                                  expense.accountId;

                                          if (currentAccountId?.isEmpty !=
                                              false) {
                                            return account.name == '내 현금' &&
                                                    account.groupId == 'CASH'
                                                ? const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16,
                                                  )
                                                : null;
                                          }

                                          return currentAccountId == account.id
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                )
                                              : null;
                                        }(),
                                      ),
                                      onTap: () {
                                        // 임시 데이터에 새 계정 저장 (전역 상태 변경 없이)
                                        if (!tempEditedRecords
                                            .containsKey(expense.id)) {
                                          tempEditedRecords[expense.id] = {};
                                        }
                                        tempEditedRecords[expense.id]![
                                            'accountId'] = account.id;
                                        tempEditedRecords[expense.id]![
                                            'accountName'] = account.name;
                                        tempEditedRecords.refresh(); // 상태 갱신
                                        hasChanges.value = true;
                                        Get.back();
                                      },
                                    ),
                                  ))
                              .toList(),
                          SizedBox(height: 8.h),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // 금액 태그 위젯
  Widget _buildAmountTag(BuildContext context, double amount, bool isIncome) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (isIncome ? Colors.green : Colors.red).withAlpha(10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        FormattingUtils.formatNumberWithCommasAndWon(amount),
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// 가로선을 그리는 CustomPainter 클래스
class StrikeThroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withAlpha(70)
      ..strokeWidth = 2.0 // 두께
      ..style = PaintingStyle.stroke;

    // 가로선 그리기
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
