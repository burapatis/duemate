class DashboardSummary {
  const DashboardSummary({
    required this.tasksToday,
    required this.overdueTasks,
    required this.completedTasks,
  });

  final int tasksToday;
  final int overdueTasks;
  final int completedTasks;
}

class UpcomingTask {
  const UpcomingTask({
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
    tasksToday: 5,
    overdueTasks: 1,
    completedTasks: 12,
  );

  static const upcomingTasks = <UpcomingTask>[
    UpcomingTask(
      title: 'ส่งรายงานสรุปงานประจำสัปดาห์',
      dueLabel: 'ครบกำหนด วันนี้ 18:00',
      priority: 'สูง',
    ),
    UpcomingTask(
      title: 'ชำระค่าน้ำประปา',
      dueLabel: 'ครบกำหนด พรุ่งนี้ 09:00',
      priority: 'กลาง',
    ),
    UpcomingTask(
      title: 'นัดคุยแผนโปรเจกต์กับทีม',
      dueLabel: 'ครบกำหนด ศุกร์ 14:30',
      priority: 'สูง',
    ),
  ];
}
