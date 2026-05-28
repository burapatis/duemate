class DashboardSummary {
  const DashboardSummary({
    required this.dueToday,
    required this.overdue,
    required this.total,
  });

  final int dueToday;
  final int overdue;
  final int total;
}

class UpcomingDocument {
  const UpcomingDocument({
    required this.title,
    required this.dueLabel,
    required this.priority,
  });

  final String title;
  final String dueLabel;
  final String priority;
}

class MockDashboardData {
  static const summary = DashboardSummary(
    dueToday: 1,
    overdue: 1,
    total: 4,
  );

  static const upcomingDocuments = <UpcomingDocument>[
    UpcomingDocument(
      title: 'พ.ร.บ. รถยนต์',
      dueLabel: 'ครบกำหนด วันนี้ 18:00',
      priority: 'สูง',
    ),
    UpcomingDocument(
      title: 'ใบขับขี่',
      dueLabel: 'ครบกำหนด 15 มิ.ย. 2569',
      priority: 'กลาง',
    ),
    UpcomingDocument(
      title: 'ประกันเครื่องซักผ้า',
      dueLabel: 'ครบกำหนด 22 ก.ค. 2569',
      priority: 'ต่ำ',
    ),
    UpcomingDocument(
      title: 'สัญญาเช่าบ้าน',
      dueLabel: 'ครบกำหนด 30 ก.ย. 2569',
      priority: 'สูง',
    ),
  ];
}
