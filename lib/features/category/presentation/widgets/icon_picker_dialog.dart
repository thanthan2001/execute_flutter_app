import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Dialog để chọn icon từ FontAwesome
class IconPickerDialog extends StatefulWidget {
  final IconData? selectedIcon;

  const IconPickerDialog({
    super.key,
    this.selectedIcon,
  });

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  IconData? _selectedIcon;
  String _searchQuery = '';

  // Danh sách icons phổ biến từ FontAwesome
  static final List<Map<String, dynamic>> _iconList = [
    {'icon': FontAwesomeIcons.utensils, 'name': 'Ăn uống'},
    {'icon': FontAwesomeIcons.car, 'name': 'Di chuyển'},
    {'icon': FontAwesomeIcons.shoppingBag, 'name': 'Mua sắm'},
    {'icon': FontAwesomeIcons.gamepad, 'name': 'Giải trí'},
    {'icon': FontAwesomeIcons.heartPulse, 'name': 'Sức khỏe'},
    {'icon': FontAwesomeIcons.graduationCap, 'name': 'Giáo dục'},
    {'icon': FontAwesomeIcons.home, 'name': 'Nhà cửa'},
    {'icon': FontAwesomeIcons.shirt, 'name': 'Quần áo'},
    {'icon': FontAwesomeIcons.gift, 'name': 'Quà tặng'},
    {'icon': FontAwesomeIcons.plane, 'name': 'Du lịch'},
    {'icon': FontAwesomeIcons.dumbbell, 'name': 'Thể thao'},
    {'icon': FontAwesomeIcons.mobile, 'name': 'Điện thoại'},
    {'icon': FontAwesomeIcons.wifi, 'name': 'Internet'},
    {'icon': FontAwesomeIcons.bolt, 'name': 'Điện nước'},
    {'icon': FontAwesomeIcons.paw, 'name': 'Thú cưng'},
    {'icon': FontAwesomeIcons.book, 'name': 'Sách'},
    {'icon': FontAwesomeIcons.film, 'name': 'Phim ảnh'},
    {'icon': FontAwesomeIcons.music, 'name': 'Âm nhạc'},
    {'icon': FontAwesomeIcons.moneyBill, 'name': 'Lương'},
    {'icon': FontAwesomeIcons.chartLine, 'name': 'Đầu tư'},
    {'icon': FontAwesomeIcons.piggyBank, 'name': 'Tiết kiệm'},
    {'icon': FontAwesomeIcons.handHoldingDollar, 'name': 'Thưởng'},
    {'icon': FontAwesomeIcons.calculator, 'name': 'Kế toán'},
    {'icon': FontAwesomeIcons.creditCard, 'name': 'Thẻ tín dụng'},
    {'icon': FontAwesomeIcons.hospital, 'name': 'Bệnh viện'},
    {'icon': FontAwesomeIcons.pills, 'name': 'Thuốc'},
    {'icon': FontAwesomeIcons.suitcase, 'name': 'Công tác'},
    {'icon': FontAwesomeIcons.briefcase, 'name': 'Làm việc'},
    {'icon': FontAwesomeIcons.baby, 'name': 'Em bé'},
    {'icon': FontAwesomeIcons.users, 'name': 'Gia đình'},
    {'icon': FontAwesomeIcons.heart, 'name': 'Yêu thương'},
    {'icon': FontAwesomeIcons.star, 'name': 'Đặc biệt'},
    {'icon': FontAwesomeIcons.fire, 'name': 'Hot'},
    {'icon': FontAwesomeIcons.leaf, 'name': 'Môi trường'},
    {'icon': FontAwesomeIcons.tools, 'name': 'Công cụ'},
    {'icon': FontAwesomeIcons.wrench, 'name': 'Sửa chữa'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.selectedIcon;
  }

  List<Map<String, dynamic>> get _filteredIcons {
    if (_searchQuery.isEmpty) {
      return _iconList;
    }
    return _iconList
        .where((item) => item['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.collections, color: Colors.blue),
                const SizedBox(width: 12),
                const Text(
                  'Chọn icon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm icon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Icon grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _filteredIcons.length,
                itemBuilder: (context, index) {
                  final item = _filteredIcons[index];
                  final icon = item['icon'] as IconData;
                  final name = item['name'] as String;
                  final isSelected = _selectedIcon == icon;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            icon,
                            size: 32,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[700],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedIcon == null
                      ? null
                      : () => Navigator.of(context).pop(_selectedIcon),
                  child: const Text('Chọn'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
