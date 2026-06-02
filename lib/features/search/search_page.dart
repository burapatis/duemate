import 'package:flutter/material.dart';

import '../../services/due_mate_services.dart';
import '../../theme/duemate_widgets.dart';
import '../home/reminder_detail_page.dart';
import '../home/reminder_item.dart';
import '../home/reminder_ui.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.services,
    required this.onItemChanged,
    this.embedded = false,
  });

  final DueMateServices services;
  final Future<void> Function(Object? result) onItemChanged;
  final bool embedded;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static List<String> get _categories => ReminderUi.filterCategories;

  final _searchController = TextEditingController();
  String _selectedCategory = 'ทั้งหมด';
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
      final loading = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('กำลังโหลดรายการ...'),
          ],
        ),
      );
      if (widget.embedded) return loading;
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: ReminderUi.backButton(
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('ค้นหา'),
        ),
        body: loading,
      );
    }

    final results = _filteredItems();
    final mutedStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final body = Column(
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
                      return KeyedSubtree(
                        key: ValueKey(item.id),
                        child: DueMateWidgets.reminderListTile(
                          context: context,
                          item: item,
                          onTap: () => _openDetail(context, item),
                        ),
                      );
                    },
                  ),
          ),
        ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ReminderUi.backButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('ค้นหา'),
      ),
      body: body,
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
