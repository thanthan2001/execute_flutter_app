# Custom Widgets Guide - Advanced

## Tổng quan các Custom Widgets mới

### 1. **AppCard** - Custom Card widget
```dart
// Cách dùng cơ bản
AppCard(
  child: Text('Content'),
)

// Card với padding
AppCard.padded(
  child: Column(children: [...]),
)

// Card có thể click
AppCard.clickable(
  onTap: () {},
  child: Text('Click me'),
)
```

### 2. **AppListTile** - Custom ListTile widget
```dart
// ListTile navigation (có icon + chevron)
AppListTile.navigation(
  icon: Icons.backup,
  title: 'Sao lưu & Khôi phục',
  subtitle: 'Quản lý backup',
  iconColor: Colors.blue,
  onTap: () {},
)

// ListTile với switch
AppListTile.withSwitch(
  icon: Icons.dark_mode,
  title: 'Chế độ tối',
  value: isDarkMode,
  onChanged: (value) {},
)

// ListTile custom
AppListTile(
  leading: Icon(Icons.settings),
  title: Text('Settings'),
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)
```

### 3. **AppText** - Typography system
```dart
// Headings
AppText.heading1('Display Text')  // 32px, bold
AppText.heading2('Main Title')    // 24px, bold
AppText.heading3('Subtitle')      // 20px, w600
AppText.heading4('Section')       // 18px, w600

// Body text
AppText.body('Normal text')       // 16px
AppText.bodySmall('Smaller text') // 14px

// Small text
AppText.caption('Caption text')   // 12px, grey
AppText.label('Label')            // 14px, w600
AppText.overline('TAG')           // 10px, uppercase

// Với màu tùy chỉnh
AppText.heading2('Title', color: Colors.blue)
AppText.body('Text', maxLines: 2, overflow: TextOverflow.ellipsis)
```

### 4. **AppDialog** - Dialog helpers
```dart
// Confirm dialog
final confirmed = await AppDialog.showConfirm(
  context: context,
  title: 'Xác nhận xóa',
  message: 'Bạn có chắc muốn xóa?',
  confirmText: 'Xóa',
  cancelText: 'Hủy',
  isDanger: true, // Nút đỏ cho hành động nguy hiểm
);

// Loading dialog
AppDialog.showLoading(context: context, message: 'Đang xử lý...');
// ... thực hiện công việc
AppDialog.hideLoading(context);

// Info dialog
await AppDialog.showInfo(
  context: context,
  title: 'Thông báo',
  message: 'Thao tác thành công!',
);

// Error dialog
await AppDialog.showError(
  context: context,
  message: 'Có lỗi xảy ra',
);

// Success dialog
await AppDialog.showSuccess(
  context: context,
  message: 'Backup thành công!',
);

// Options bottom sheet
final selected = await AppDialog.showOptions<String>(
  context: context,
  title: 'Chọn tùy chọn',
  options: [
    AppDialogOption(label: 'Tùy chọn 1', value: 'option1', icon: Icons.check),
    AppDialogOption(label: 'Tùy chọn 2', value: 'option2', icon: Icons.close),
  ],
);
```

### 5. **AppSnackBar** - SnackBar helpers
```dart
// Success snackbar
AppSnackBar.showSuccess(context, 'Lưu thành công!');

// Error snackbar
AppSnackBar.showError(context, 'Có lỗi xảy ra');

// Info snackbar
AppSnackBar.showInfo(context, 'Thông tin');

// Warning snackbar
AppSnackBar.showWarning(context, 'Cảnh báo!');

// Custom snackbar
AppSnackBar.show(
  context,
  'Custom message',
  backgroundColor: Colors.purple,
  icon: Icons.star,
  duration: Duration(seconds: 5),
);
```

## Migration Guide

### Thay thế Card

**Cũ:**
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text('Content'),
  ),
)
```

**Mới:**
```dart
AppCard.padded(
  child: Text('Content'),
)
```

### Thay thế ListTile navigation

**Cũ:**
```dart
ListTile(
  leading: Icon(Icons.settings, color: Colors.blue),
  title: Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
  subtitle: Text('Cài đặt ứng dụng', style: TextStyle(fontSize: 12)),
  trailing: Icon(Icons.chevron_right),
  onTap: () {},
)
```

**Mới:**
```dart
AppListTile.navigation(
  icon: Icons.settings,
  iconColor: Colors.blue,
  title: 'Settings',
  subtitle: 'Cài đặt ứng dụng',
  onTap: () {},
)
```

### Thay thế Text

**Cũ:**
```dart
Text(
  'Heading',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
)

Text(
  'Body text',
  style: TextStyle(fontSize: 16),
)

Text(
  'Caption',
  style: TextStyle(fontSize: 12, color: Colors.grey),
)
```

**Mới:**
```dart
AppText.heading2('Heading')
AppText.body('Body text')
AppText.caption('Caption')
```

### Thay thế showDialog

**Cũ:**
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Xác nhận'),
    content: Text('Bạn có chắc?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Hủy'),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('OK'),
      ),
    ],
  ),
);
```

**Mới:**
```dart
final confirmed = await AppDialog.showConfirm(
  context: context,
  title: 'Xác nhận',
  message: 'Bạn có chắc?',
);
```

### Thay thế SnackBar

**Cũ:**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Thành công'),
    backgroundColor: Colors.green,
  ),
);
```

**Mới:**
```dart
AppSnackBar.showSuccess(context, 'Thành công');
```

### Thay thế Loading Dialog

**Cũ:**
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => AlertDialog(
    content: Row(
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 16),
        Text('Đang tải...'),
      ],
    ),
  ),
);
// ... xử lý
Navigator.pop(context);
```

**Mới:**
```dart
AppDialog.showLoading(context: context, message: 'Đang tải...');
// ... xử lý
AppDialog.hideLoading(context);
```

## Lợi ích

1. **Consistency**: Design system nhất quán toàn app
2. **Maintainability**: Chỉ cần sửa 1 chỗ để thay đổi style toàn app
3. **Productivity**: Code ngắn gọn, dễ đọc, dễ viết
4. **Best Practices**: Built-in accessibility, responsive design
5. **Type Safety**: Compile-time checking cho styles

## Next Steps

Để apply toàn bộ app:
1. Import `import '../../../../global/widgets/widgets.dart';` thay vì import từng widget
2. Find & Replace các widget cũ bằng custom widgets mới
3. Test kỹ để đảm bảo không có regression
4. Có thể extend thêm variants mới khi cần

## Ví dụ: Refactor một Screen hoàn chỉnh

**Before:**
```dart
Card(
  child: ListTile(
    leading: Icon(Icons.backup, color: Colors.blue),
    title: Text(
      'Backup',
      style: TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      'Sao lưu dữ liệu',
      style: TextStyle(fontSize: 12),
    ),
    trailing: Icon(Icons.chevron_right),
    onTap: () async {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Đang backup...'),
            ],
          ),
        ),
      );
      
      // Do backup
      await Future.delayed(Duration(seconds: 2));
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup thành công'),
          backgroundColor: Colors.green,
        ),
      );
    },
  ),
)
```

**After:**
```dart
AppCard(
  child: AppListTile.navigation(
    icon: Icons.backup,
    iconColor: Colors.blue,
    title: 'Backup',
    subtitle: 'Sao lưu dữ liệu',
    onTap: () async {
      AppDialog.showLoading(context: context, message: 'Đang backup...');
      
      // Do backup
      await Future.delayed(Duration(seconds: 2));
      
      AppDialog.hideLoading(context);
      AppSnackBar.showSuccess(context, 'Backup thành công');
    },
  ),
)
```

**Kết quả:** Code ngắn hơn 40%, dễ đọc và maintain hơn nhiều!
