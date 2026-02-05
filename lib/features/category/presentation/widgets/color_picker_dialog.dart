import 'package:flutter/material.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../global/widgets/widgets.dart';

/// Dialog để chọn màu sắc
class ColorPickerDialog extends StatefulWidget {
  final Color? selectedColor;

  const ColorPickerDialog({
    super.key,
    this.selectedColor,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color? _selectedColor;

  // Palette màu đẹp và hài hòa
  static const List<Color> _colorPalette = [
    AppColors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    AppColors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Color(0xFFE91E63), // Pink accent
    Color(0xFF9C27B0), // Purple accent
    Color(0xFF673AB7), // Deep Purple accent
    Color(0xFF3F51B5), // Indigo accent
    Color(0xFF2196F3), // Blue accent
    Color(0xFF00BCD4), // Cyan accent
    Color(0xFF009688), // Teal accent
    Color(0xFF4CAF50), // Green accent
    Color(0xFFFFEB3B), // Yellow accent
    Color(0xFFFF9800), // Orange accent
    Color(0xFFFF5722), // Deep Orange accent
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor ?? _colorPalette[0];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.palette, color: Colors.blue),
                const SizedBox(width: 12),
                AppText.heading4('Chọn màu sắc'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Preview
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        _selectedColor?.withOpacity(0.3) ?? Colors.transparent,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: AppText.body(
                  'Màu đã chọn',
                  color: _getContrastColor(_selectedColor!),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Color grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _colorPalette.length,
                itemBuilder: (context, index) {
                  final color = _colorPalette[index];
                  final isSelected = _selectedColor == color;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _getContrastColor(color),
                              size: 28,
                            )
                          : null,
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
                AppButton.text(
                  text: 'Hủy',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                AppButton.primary(
                  text: 'Chọn',
                  onPressed: () => Navigator.of(context).pop(_selectedColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy màu contrast để text dễ đọc
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
