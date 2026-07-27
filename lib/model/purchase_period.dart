/// 구매 지출 리포트의 집계 단위.
enum PurchasePeriod {
  /// 최근 30일, 일 단위 (yyyy-MM-dd)
  daily,

  /// 최근 12개월, 월 단위 (yyyy-MM)
  monthly,

  /// 전체 기간, 연 단위 (yyyy)
  yearly,
}
