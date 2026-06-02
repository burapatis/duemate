import 'package:flutter/material.dart';

import '../../services/due_mate_services.dart';
import '../home/reminder_detail_page.dart';
import '../home/reminder_item.dart';
import '../home/reminder_ui.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.services,
    required this.onItemChanged,
  });

  final DueMateServices services;

  /// แจ้ง Home เมื่อแก้ไข/ลบจาก Detail — Home จะบันทึกและปรับการแจ้งเตือน
  final Future<void> Function(Object? result) onItemChanged;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _categories = <String>[
    'ทั้งหมด',
    'รถ',
    'ส่วนตัว',
    'บ้าน',
    'ครอบครัว',
    'สินค้า/รับประกัน',
    'งาน/ราชการ',
    'อื่น ๆ',
  ];

  final _searchController = TextEditingController();
  String _selectedCategory = _categories.first;
  List<ReminderItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reloadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// โหลดรายการล่าสุดจากเครื่อง — ไม่ใช้ snapshot ตอนเปิดหน้า
  Future<void> _reloadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await widget.services.storage.loadReminders();
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = [];
        _isLoading = false;
      });
    }
  }

  List<ReminderItem> _filteredItems() {
    return filterReminderItems(
      items: _items,
      query: _searchController.text,
      selectedCategory: _selectedCategory,
    );
  }

  String _formatDueLabel(DateTime dueDate) {
    final day = dueDate.day.toString().padLeft(2, '0');
    final month = dueDate.month.toString().padLeft(2, '0');
    final year = dueDate.year + 543;
    return 'ครบกำหนด $day/$month/$year';
  }

  Future<void> _openDetail(BuildContext context, ReminderItem item) async {
    final result = await Navigator.of(context).push<Object>(
      MaterialPageRoute(
        builder: (_) => ReminderDetailPage(
          item: item,
          notificationService: widget.services.notificationService,
        ),
      ),
    );

    if (result == null || !context.mounted) return;

    // อัปเดต Home แล้วโหลดรายการใหม่ — ยังอยู่หน้าค้นหา
    await widget.onItemChanged(result);
    if (!context.mounted) return;
    await _reloadItems();
  }

  String _resultCountLabel(int count) {
    if (count == 0) return 'ไม่พบรายการ';
    return 'พบ $count รายการ';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'กลับ',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('🔎 ค้นหาเอกสาร'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('กำลังโหลดรายการ...'),
            ],
          ),
        ),
      );
    }

    final results = _filteredItems();
    final mutedStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(
        // macOS: AppBar back แบบ default อาจไม่รับ tap — ใช้ leading ชัดเจน
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'กลับ',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('🔎 ค้นหาเอกสาร'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ReminderUi.pagePadding,
              ReminderUi.pagePadding,
              ReminderUi.pagePadding,
              ReminderUi.sectionGap,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(ReminderUi.cardPadding),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'ค้นหาด้วยชื่อรายการ',
                        hintText: 'เช่น ใบขับขี่, พ.ร.บ. รถยนต์',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'กรองหมวด',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(ReminderUi.filterCategoryLabel(category)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ReminderUi.pagePadding,
              0,
              ReminderUi.pagePadding,
              ReminderUi.sectionGap,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_resultCountLabel(results.length), style: mutedStyle),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const _SearchEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      ReminderUi.pagePadding,
                      4,
                      ReminderUi.pagePadding,
                      ReminderUi.pagePadding,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return Card(
                        key: ValueKey(item.id),
                        margin: const EdgeInsets.only(bottom: ReminderUi.sectionGap),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            '${ReminderUi.categoryLabel(item.category)} • ${_formatDueLabel(item.dueDate)}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openDetail(context, item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// กรองรายการตามคำค้นหาและหมวด — ใช้ในหน้าค้นหาและ unit test
List<ReminderItem> filterReminderItems({
  required List<ReminderItem> items,
  required String query,
  required String selectedCategory,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return items.where((item) {
    final matchesName =
        normalizedQuery.isEmpty ||
        item.title.toLowerCase().contains(normalizedQuery);
    final matchesCategory =
        selectedCategory == 'ทั้งหมด' || item.category == selectedCategory;
    return matchesName && matchesCategory;
  }).toList();
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    final mutedStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ReminderUi.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'ไม่พบรายการที่ตรงกับการค้นหา',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ลองเปลี่ยนคำค้นหา หรือเลือกหมวดทั้งหมด',
              style: mutedStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
