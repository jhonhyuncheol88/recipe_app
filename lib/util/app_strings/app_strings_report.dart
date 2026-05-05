import '../app_locale.dart';

/// 리포트 관련 문자열 (6개 로케일)
mixin AppStringsReport {
  static String getReport(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '리포트';
      case AppLocale.japan:
        return 'レポート';
      case AppLocale.china:
        return '报告';
      case AppLocale.usa:
        return 'Report';
      case AppLocale.chinaTraditional:
        return 'Bericht';
      case AppLocale.vietnam:
        return 'Báo cáo';
    }
  }

  static String getReportSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원가·재고·마진 한눈에';
      case AppLocale.japan:
        return '原価・在庫・利益を一目で';
      case AppLocale.china:
        return '一览成本、库存与利润';
      case AppLocale.usa:
        return 'Cost, inventory & margin at a glance';
      case AppLocale.chinaTraditional:
        return 'Kosten, Lager & Marge auf einen Blick';
      case AppLocale.vietnam:
        return 'Chi phí, tồn kho & lợi nhuận';
    }
  }

  static String getPeriodWeekly(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '주간';
      case AppLocale.japan:
        return '週間';
      case AppLocale.china:
        return '周';
      case AppLocale.usa:
        return 'Weekly';
      case AppLocale.chinaTraditional:
        return 'Wöchentlich';
      case AppLocale.vietnam:
        return 'Tuần';
    }
  }

  static String getPeriodMonthly(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '월간';
      case AppLocale.japan:
        return '月間';
      case AppLocale.china:
        return '月';
      case AppLocale.usa:
        return 'Monthly';
      case AppLocale.chinaTraditional:
        return 'Monatlich';
      case AppLocale.vietnam:
        return 'Tháng';
    }
  }

  static String getPeriodQuarterly(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '분기';
      case AppLocale.japan:
        return '四半期';
      case AppLocale.china:
        return '季度';
      case AppLocale.usa:
        return 'Quarterly';
      case AppLocale.chinaTraditional:
        return 'Quartal';
      case AppLocale.vietnam:
        return 'Quý';
    }
  }

  static String getAvgCostRatio(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '평균 원가율';
      case AppLocale.japan:
        return '平均原価率';
      case AppLocale.china:
        return '平均成本率';
      case AppLocale.usa:
        return 'Avg. Cost Ratio';
      case AppLocale.chinaTraditional:
        return 'Ø Kostenquote';
      case AppLocale.vietnam:
        return 'Tỷ lệ chi phí TB';
    }
  }

  static String getGoalAchieved(AppLocale locale, int target) {
    switch (locale) {
      case AppLocale.korea:
        return '목표 $target% 달성';
      case AppLocale.japan:
        return '目標 $target% 達成';
      case AppLocale.china:
        return '达成目标 $target%';
      case AppLocale.usa:
        return 'Goal $target% achieved';
      case AppLocale.chinaTraditional:
        return 'Ziel $target% erreicht';
      case AppLocale.vietnam:
        return 'Đạt mục tiêu $target%';
    }
  }

  static String getDeltaVsPrevPeriod(AppLocale locale, ReportPeriodLabel period) {
    switch (locale) {
      case AppLocale.korea:
        switch (period) {
          case ReportPeriodLabel.weekly:
            return '전주 대비';
          case ReportPeriodLabel.monthly:
            return '전월 대비';
          case ReportPeriodLabel.quarterly:
            return '전분기 대비';
        }
      case AppLocale.japan:
        switch (period) {
          case ReportPeriodLabel.weekly:
            return '前週比';
          case ReportPeriodLabel.monthly:
            return '前月比';
          case ReportPeriodLabel.quarterly:
            return '前四半期比';
        }
      case AppLocale.china:
        switch (period) {
          case ReportPeriodLabel.weekly:
            return '与上周对比';
          case ReportPeriodLabel.monthly:
            return '与上月对比';
          case ReportPeriodLabel.quarterly:
            return '与上季度对比';
        }
      case AppLocale.usa:
        switch (period) {
          case ReportPeriodLabel.weekly:
            return 'vs prev. week';
          case ReportPeriodLabel.monthly:
            return 'vs prev. month';
          case ReportPeriodLabel.quarterly:
            return 'vs prev. quarter';
        }
      case AppLocale.chinaTraditional:
        switch (period) {
          case ReportPeriodLabel.weekly:
            return 'gg. Vorwoche';
          case ReportPeriodLabel.monthly:
            return 'gg. Vormonat';
          case ReportPeriodLabel.quarterly:
            return 'gg. Vorquartal';
        }
      case AppLocale.vietnam:
        switch (period) {
          case ReportPeriodLabel.weekly:
            return 'so với tuần trước';
          case ReportPeriodLabel.monthly:
            return 'so với tháng trước';
          case ReportPeriodLabel.quarterly:
            return 'so với quý trước';
        }
    }
  }

  static String getInventoryValue(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재고 가치 구성';
      case AppLocale.japan:
        return '在庫価値構成';
      case AppLocale.china:
        return '库存价值构成';
      case AppLocale.usa:
        return 'Inventory Composition';
      case AppLocale.chinaTraditional:
        return 'Lagerwert-Struktur';
      case AppLocale.vietnam:
        return 'Cơ cấu giá trị tồn kho';
    }
  }

  static String getInventorySubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '분류별 재고 평가액';
      case AppLocale.japan:
        return 'カテゴリ別在庫評価額';
      case AppLocale.china:
        return '按分类的库存评估值';
      case AppLocale.usa:
        return 'Inventory value by category';
      case AppLocale.chinaTraditional:
        return 'Lagerwert nach Kategorie';
      case AppLocale.vietnam:
        return 'Giá trị tồn kho theo danh mục';
    }
  }

  static String getTotalInventory(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총 재고';
      case AppLocale.japan:
        return '総在庫';
      case AppLocale.china:
        return '总库存';
      case AppLocale.usa:
        return 'Total inventory';
      case AppLocale.chinaTraditional:
        return 'Gesamtlager';
      case AppLocale.vietnam:
        return 'Tổng tồn kho';
    }
  }

  static String getUncategorized(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '미분류';
      case AppLocale.japan:
        return '未分類';
      case AppLocale.china:
        return '未分类';
      case AppLocale.usa:
        return 'Uncategorized';
      case AppLocale.chinaTraditional:
        return 'Unkategorisiert';
      case AppLocale.vietnam:
        return 'Chưa phân loại';
    }
  }

  static String getOtherCategories(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '기타';
      case AppLocale.japan:
        return 'その他';
      case AppLocale.china:
        return '其他';
      case AppLocale.usa:
        return 'Other';
      case AppLocale.chinaTraditional:
        return 'Sonstige';
      case AppLocale.vietnam:
        return 'Khác';
    }
  }

  static String getMarginRanking(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '마진율 순위';
      case AppLocale.japan:
        return '利益率ランキング';
      case AppLocale.china:
        return '利润率排名';
      case AppLocale.usa:
        return 'Margin Ranking';
      case AppLocale.chinaTraditional:
        return 'Margen-Ranking';
      case AppLocale.vietnam:
        return 'Xếp hạng biên lợi nhuận';
    }
  }

  static String getViewAll(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '전체보기';
      case AppLocale.japan:
        return '全て見る';
      case AppLocale.china:
        return '查看全部';
      case AppLocale.usa:
        return 'View all';
      case AppLocale.chinaTraditional:
        return 'Alle ansehen';
      case AppLocale.vietnam:
        return 'Xem tất cả';
    }
  }

  static String getExpensiveIngredientsTop5(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '비싼 재료 TOP 5';
      case AppLocale.japan:
        return '高価な食材 TOP 5';
      case AppLocale.china:
        return '最贵食材 TOP 5';
      case AppLocale.usa:
        return 'Top 5 Expensive Ingredients';
      case AppLocale.chinaTraditional:
        return 'Top 5 teuerste Zutaten';
      case AppLocale.vietnam:
        return 'TOP 5 nguyên liệu đắt nhất';
    }
  }

  static String getUnitPriceBasis(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '단가 기준';
      case AppLocale.japan:
        return '単価基準';
      case AppLocale.china:
        return '按单价';
      case AppLocale.usa:
        return 'By unit price';
      case AppLocale.chinaTraditional:
        return 'nach Stückpreis';
      case AppLocale.vietnam:
        return 'Theo đơn giá';
    }
  }

  static String getEmptyHistoryPrompt(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피를 수정하면 추적이 시작됩니다';
      case AppLocale.japan:
        return 'レシピを編集すると追跡が開始されます';
      case AppLocale.china:
        return '编辑食谱后开始跟踪';
      case AppLocale.usa:
        return 'Edit a recipe to start tracking';
      case AppLocale.chinaTraditional:
        return 'Rezept bearbeiten, um Tracking zu starten';
      case AppLocale.vietnam:
        return 'Chỉnh sửa công thức để bắt đầu theo dõi';
    }
  }

  static String getEmptyReportPrompt(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '표시할 데이터가 없습니다';
      case AppLocale.japan:
        return '表示するデータがありません';
      case AppLocale.china:
        return '暂无数据';
      case AppLocale.usa:
        return 'No data to display';
      case AppLocale.chinaTraditional:
        return 'Keine Daten vorhanden';
      case AppLocale.vietnam:
        return 'Không có dữ liệu để hiển thị';
    }
  }
}

/// 내부 helper enum — getDeltaVsPrevPeriod 에서 switch 를 위해 사용
enum ReportPeriodLabel { weekly, monthly, quarterly }
