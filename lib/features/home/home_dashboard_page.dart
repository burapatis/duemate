import 'package:flutter/material.dart';

import '../../services/due_mate_services.dart';
import '../../services/local_reminder_storage.dart';
import '../../services/notification_service.dart';
import '../../theme/app_brand_colors.dart';
import '../../theme/duemate_widgets.dart';
import '../add/add_reminder_page.dart';
import '../export/export_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import 'due_date_helper.dart';
import 'mock_dashboard_data.dart' show DashboardSummary;
import 'reminder_detail_page.dart';
import 'reminder_item.dart';
import 'reminder_ui.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({
    super.key,
    required this.services,
    required this.onThemeModeChanged,
  });

  final DueMateServices services;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  static List<String> get _filterCategories => ReminderUi.filterCategories;

  LocalReminderStorage get _storage => widget.services.storage;
  NotificationService get _notificationService =>
      widget.services.notificationService;
  bool _isLoading = true;
  List<ReminderItem> _upcomingDocuments = [];
  String _selectedCategory = 'ทั้งหมด';
  bool _hideCompleted = false;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _storage.loadReminders();

      if (!mounted) return;
      setState(() {
        _upcomingDocuments = result.items;
        _isLoading = false;
      });

      if (result.skippedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'บางรายการโหลดไม่ได้ (${result.skippedCount} รายการ) '
              'รายการที่เหลือยังใช้งานได้',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _upcomingDocuments = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โหลดข้อมูลไม่สำเร็จ กรุณาลองใหม่')),
      );
    }
  }

  Future<void> _persistReminders() async {
    try {
      await _storage.saveReminders(_upcomingDocuments);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกลงเครื่องไม่สำเร็จ กรุณาลองใหม่')),
      );
    }
  }

  void _clearRemindersInMemory() {
    setState(() {
      _upcomingDocuments = [];
    });
  }

  List<ReminderItem> _visibleAndSortedItems() {
    final filtered = _upcomingDocuments.where((item) {
      if (_hideCompleted && item.isCompleted) return false;
      if (_selectedCategory != 'ทั้งหมด' &&
          item.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort(DueDateHelper.compareReminders);
    return filtered;
  }

  Future<void> _openSettings() async {
    setState(() {
      _navIndex = 2;
    });
  }

  void _openExport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExportPage(
          items: _upcomingDocuments,
          exportService: widget.services.exportService,
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'กรองรายการ',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _filterCategories.map((category) {
                      final selected = _selectedCategory == category;
                      return FilterChip(
                        label: Text(ReminderUi.filterCategoryLabel(category)),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                          setSheetState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('ซ่อนรายการที่เสร็จแล้ว'),
                    subtitle: const Text(
                      'ปิดไว้เพื่อให้เห็นรายการที่เสร็จแล้วตลอด — ข้อมูลไม่ถูกลบ',
                    ),
                    value: _hideCompleted,
                    onChanged: (value) {
                      setState(() {
                        _hideCompleted = value;
                      });
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = _navIndex == index;
    final color = selected ? AppBrandColors.primaryBlue : Colors.grey;

    return InkWell(
      onTap: () {
        if (index == 3) {
          _openExport();
          return;
        }
        setState(() {
          _navIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Container(
                width: 20,
                height: 3,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppBrandColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 7),
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeReminderById(String id) async {
    setState(() {
      _upcomingDocuments =
          _upcomingDocuments.where((item) => item.id != id).toList();
    });

    await _persistReminders();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ลบรายการแล้ว')),
    );
  }

  Future<void> _updateReminder(ReminderItem updated) async {
    final index =
        _upcomingDocuments.indexWhere((item) => item.id == updated.id);
    if (index < 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่พบรายการนี้ กรุณากลับไปหน้าหลักแล้วลองใหม่'),
        ),
      );
      return;
    }

    final previous = _upcomingDocuments[index];

    setState(() {
      _upcomingDocuments = _upcomingDocuments
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
    });

    await _persistReminders();

    if (!mounted) return;

    if (updated.isCompleted) {
      await _notificationService.cancelRemindersForItem(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ทำเครื่องหมายเสร็จแล้ว — ข้อมูลยังอยู่ในเครื่อง '
            'รายการจะอยู่ด้านล่างและไม่แจ้งเตือนอีก',
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (previous.isCompleted && !updated.isCompleted) {
      final scheduleResult =
          await _notificationService.scheduleRemindersForItem(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            scheduleResult == ScheduleRemindersResult.partialFailure
                ? 'บันทึกแล้ว แต่ตั้งเตือนไม่สำเร็จ'
                : 'บันทึกแล้ว และตั้งเตือนแล้ว',
          ),
        ),
      );
      return;
    }

    final scheduleResult =
        await _notificationService.rescheduleRemindersForItem(
      previous: previous,
      updated: updated,
    );

    if (!mounted) return;

    final notificationOk =
        scheduleResult != ScheduleRemindersResult.partialFailure;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          notificationOk
              ? 'บันทึกแล้ว และตั้งเตือนแล้ว'
              : 'บันทึกแล้ว แต่ตั้งเตือนไม่สำเร็จ',
        ),
      ),
    );
  }

  Future<void> _addNewReminderFromResult(ReminderItem newItem) async {
    setState(() {
      _upcomingDocuments = [newItem, ..._upcomingDocuments];
    });

    await _persistReminders();

    if (!mounted) return;

    ScheduleRemindersResult scheduleResult;
    try {
      scheduleResult =
          await _notificationService.scheduleRemindersForItem(newItem);
    } catch (_) {
      scheduleResult = ScheduleRemindersResult.partialFailure;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (scheduleResult) {
          ScheduleRemindersResult.success =>
            'เพิ่มรายการแล้ว และตั้งเตือนแล้ว',
          ScheduleRemindersResult.noSchedulableDates =>
            'เพิ่มรายการแล้ว แต่ยังไม่ได้ตั้งเตือน',
          ScheduleRemindersResult.partialFailure =>
            'เพิ่มรายการแล้ว แต่ตั้งเตือนไม่สำเร็จ',
        }),
      ),
    );
  }

  Future<void> _handleNavigationResult(Object? result) async {
    if (result is ReminderItem) {
      final exists =
          _upcomingDocuments.any((item) => item.id == result.id);
      if (exists) {
        await _updateReminder(result);
      } else {
        await _addNewReminderFromResult(result);
      }
    } else if (result is String) {
      await _removeReminderById(result);
    }
  }

  Future<void> _openReminderDetail(ReminderItem item) async {
    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute(
        builder: (_) => ReminderDetailPage(
          item: item,
          notificationService: widget.services.notificationService,
        ),
      ),
    );

    await _handleNavigationResult(result);
  }

  Future<void> _syncRemindersFromStorage() async {
    try {
      final result = await _storage.loadReminders();
      if (!mounted) return;
      setState(() {
        _upcomingDocuments = result.items;
      });
    } catch (_) {
      // คงรายการเดิมไว้ถ้าโหลดไม่สำเร็จ
    }
  }

  Future<void> _openSearch() async {
    setState(() {
      _navIndex = 1;
    });
    await _syncRemindersFromStorage();
  }

  Future<void> _openAddReminder() async {
    final newItem = await Navigator.of(context).push<ReminderItem>(
      MaterialPageRoute(
        builder: (_) => const AddReminderPage(),
      ),
    );

    if (newItem == null) return;

    final updatedList = [newItem, ..._upcomingDocuments];
    setState(() {
      _upcomingDocuments = updatedList;
    });

    await _persistReminders();

    if (!mounted) return;

    ScheduleRemindersResult scheduleResult;
    try {
      scheduleResult =
          await _notificationService.scheduleRemindersForItem(newItem);
    } catch (_) {
      scheduleResult = ScheduleRemindersResult.partialFailure;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(switch (scheduleResult) {
          ScheduleRemindersResult.success =>
            'บันทึกแล้ว และตั้งเตือนแล้ว',
          ScheduleRemindersResult.noSchedulableDates =>
            'บันทึกแล้ว แต่ยังไม่ได้ตั้งเตือน',
          ScheduleRemindersResult.partialFailure =>
            'บันทึกแล้ว แต่ตั้งเตือนไม่สำเร็จ',
        }),
      ),
    );
  }

  DashboardSummary _buildSummary(List<ReminderItem> items) {
    var expiringSoon = 0;
    var nearing = 0;
    var normal = 0;

    for (final item in items) {
      if (item.isCompleted) continue;

      final urgency = DueDateHelper.urgencyLevel(dueDate: item.dueDate);
      switch (urgency) {
        case DueUrgency.overdue:
        case DueUrgency.dueToday:
          expiringSoon++;
        case DueUrgency.dueSoon:
          nearing++;
        case DueUrgency.normal:
          normal++;
        case DueUrgency.completed:
          break;
      }
    }

    return DashboardSummary(
      expiringSoon: expiringSoon,
      nearing: nearing,
      normal: normal,
    );
  }

  Widget _buildHomeTab() {
    final summary = _buildSummary(_upcomingDocuments);
    final visibleItems = _visibleAndSortedItems();
    final completedCount =
        visibleItems.where((item) => item.isCompleted).length;

    return Column(
      children: [
        DueMateWidgets.docsafeHeader(
          context: context,
          onSearchTap: _openSearch,
          onFilterTap: _showFilterSheet,
          onSettingsTap: _openSettings,
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              decoration: const BoxDecoration(
                color: AppBrandColors.sheetBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: RefreshIndicator(
                onRefresh: () => _loadReminders(showLoading: false),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  children: [
                    DueMateWidgets.sectionHeader(context, 'สรุปเอกสาร'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        DueMateWidgets.coloredSummaryCard(
                          background: AppBrandColors.summaryOrange,
                          label: 'หมดอายุเร็วๆ นี้',
                          count: summary.expiringSoon,
                        ),
                        const SizedBox(width: 10),
                        DueMateWidgets.coloredSummaryCard(
                          background: AppBrandColors.summaryYellow,
                          label: 'ใกล้หมดอายุ',
                          count: summary.nearing,
                        ),
                        const SizedBox(width: 10),
                        DueMateWidgets.coloredSummaryCard(
                          background: AppBrandColors.summaryGreen,
                          label: 'ปกติ',
                          count: summary.normal,
                        ),
                      ],
                    ),
                    const SizedBox(height: ReminderUi.blockGap),
                    DueMateWidgets.sectionHeader(
                      context,
                      'รายการเอกสารสำคัญ',
                    ),
                    const SizedBox(height: 12),
                    if (completedCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'มี $completedCount รายการที่ทำเครื่องหมายเสร็จแล้ว '
                          '— ข้อมูลยังอยู่ในเครื่อง',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    if (visibleItems.isEmpty)
                      DueMateWidgets.emptyStateCard(
                        context: context,
                        icon: Icons.description_outlined,
                        title: 'ยังไม่มีรายการในหมวดนี้',
                        subtitle: _upcomingDocuments.isEmpty
                            ? 'กดปุ่ม + ด้านล่างเพื่อเริ่มบันทึก'
                            : 'ลองเปลี่ยนตัวกรอง หรือปิด "ซ่อนรายการที่เสร็จแล้ว"',
                      )
                    else ...[
                      ...visibleItems.map(
                        (task) => DueMateWidgets.docsafeDocumentCard(
                          context: context,
                          item: task,
                          onTap: () => _openReminderDetail(task),
                        ),
                      ),
                      DueMateWidgets.viewAllButton(
                        context: context,
                        onTap: _openSearch,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'ข้อมูลหลักเก็บอยู่ในเครื่องนี้',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int get _stackIndex => switch (_navIndex) {
        1 => 1,
        2 => 2,
        _ => 0,
      };

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppBrandColors.primaryBlue),
              const SizedBox(height: 16),
              Text(
                'กำลังโหลดข้อมูล...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _stackIndex,
        children: [
          _buildHomeTab(),
          SearchPage(
            embedded: true,
            services: widget.services,
            onItemChanged: _handleNavigationResult,
          ),
          SettingsPage(
            embedded: true,
            services: widget.services,
            onThemeModeChanged: widget.onThemeModeChanged,
            onDataCleared: _clearRemindersInMemory,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddReminder,
        tooltip: 'เพิ่มรายการ',
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'หน้าหลัก',
            ),
            _buildBottomNavItem(
              index: 1,
              icon: Icons.search_rounded,
              label: 'ค้นหา',
            ),
            const SizedBox(width: 48),
            _buildBottomNavItem(
              index: 3,
              icon: Icons.file_upload_outlined,
              label: 'ส่งออก',
            ),
            _buildBottomNavItem(
              index: 2,
              icon: Icons.settings_outlined,
              label: 'ตั้งค่า',
            ),
          ],
        ),
      ),
    );
  }
}
