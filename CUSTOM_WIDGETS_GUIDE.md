# Custom Widgets Guide

## Giới thiệu

App đã được nâng cấp với các custom widget đẹp và nhất quán cho Button và Input. Tất cả các widget này đều có sẵn trong `lib/global/widgets/`.

## AppButton

### Các loại button

#### 1. AppButton.primary (Nút chính)
```dart
AppButton.primary(
  text: 'Lưu',
  onPressed: () {},
  icon: Icons.save, // optional
  width: double.infinity, // optional
  isLoading: false, // optional
)
```

#### 2. AppButton.secondary (Nút phụ)
```dart
AppButton.secondary(
  text: 'Hủy',
  onPressed: () {},
)
```

#### 3. AppButton.outline (Nút viền)
```dart
AppButton.outline(
  text: 'Đặt lại',
  icon: Icons.refresh,
  onPressed: () {},
)
```

#### 4. AppButton.text (Nút văn bản)
```dart
AppButton.text(
  text: 'Bỏ qua',
  onPressed: () {},
)
```

#### 5. AppButton.danger (Nút nguy hiểm)
```dart
AppButton.danger(
  text: 'Xóa',
  icon: Icons.delete,
  onPressed: () {},
)
```

### Tính năng

- ✅ Loading state tự động với spinner
- ✅ Icon support
- ✅ Custom width/height
- ✅ Disabled state
- ✅ Responsive design
- ✅ Consistent styling

## AppInput

### Input cơ bản

```dart
AppInput(
  controller: controller,
  labelText: 'Số tiền',
  prefixIcon: Icons.attach_money,
  suffixText: 'đ',
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Vui lòng nhập số tiền';
    }
    return null;
  },
)
```

### AppPasswordInput (Input mật khẩu)

```dart
AppPasswordInput(
  controller: passwordController,
  labelText: 'Mật khẩu',
  validator: (value) {
    // validation logic
  },
)
```

Tự động có:
- Icon khóa
- Toggle hiển thị/ẩn mật khẩu

### AppSearchInput (Input tìm kiếm)

```dart
AppSearchInput(
  controller: searchController,
  hintText: 'Tìm kiếm...',
  onChanged: (value) {
    // search logic
  },
  onClear: () {
    searchController.clear();
  },
)
```

Tự động có:
- Icon tìm kiếm
- Nút xóa khi có text

### Các thuộc tính của AppInput

```dart
AppInput(
  controller: controller,
  labelText: 'Label',
  hintText: 'Hint text',
  helperText: 'Helper text',
  errorText: 'Error text',
  
  // Icons
  prefixIcon: Icons.email,
  suffixIcon: Icons.clear,
  onSuffixIconTap: () {},
  
  // Text formatting
  prefixText: '\$',
  suffixText: 'VND',
  
  // Input type
  keyboardType: TextInputType.number,
  textInputAction: TextInputAction.next,
  
  // Behavior
  obscureText: false,
  readOnly: false,
  enabled: true,
  
  // Validation
  validator: (value) => null,
  
  // Lines
  maxLines: 1,
  maxLength: 100,
  
  // Input formatters
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
  
  // Callbacks
  onChanged: (value) {},
  onTap: () {},
  onSubmitted: (value) {},
  
  // Styling
  filled: true,
  fillColor: Colors.grey[50],
  contentPadding: EdgeInsets.all(16),
)
```

## Tính năng chung

### 1. Focus State
- Border color tự động đổi khi focus
- Icon color tự động đổi khi focus
- Background color thay đổi nhẹ khi focus

### 2. Error State
- Border đỏ khi có lỗi
- Error message hiển thị bên dưới
- Icon giữ nguyên màu

### 3. Disabled State
- Màu xám nhạt
- Không thể tương tác
- Visual feedback rõ ràng

### 4. Validation
- Hỗ trợ FormField validation
- Error message tự động hiển thị
- Integration với Form widget

## Import

```dart
// Import individual widgets
import 'package:my_clean_app/global/widgets/app_button.dart';
import 'package:my_clean_app/global/widgets/app_input.dart';

// Hoặc import tất cả
import 'package:my_clean_app/global/widgets/widgets.dart';
```

## Ví dụ sử dụng

### Form đầy đủ

```dart
class MyForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppInput(
            controller: _emailController,
            labelText: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          
          AppPasswordInput(
            controller: _passwordController,
            labelText: 'Mật khẩu',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập mật khẩu';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          
          AppButton.primary(
            text: 'Đăng nhập',
            width: double.infinity,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Submit form
              }
            },
          ),
        ],
      ),
    );
  }
}
```

### Dialog với buttons

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Xác nhận xóa'),
    content: Text('Bạn có chắc muốn xóa?'),
    actions: [
      AppButton.text(
        text: 'Hủy',
        onPressed: () => Navigator.pop(context),
      ),
      AppButton.danger(
        text: 'Xóa',
        onPressed: () {
          // Delete logic
          Navigator.pop(context);
        },
      ),
    ],
  ),
);
```

## Design System

### Colors
- Primary: Theme primary color
- Secondary: Grey[100] background
- Danger: Red[600]
- Border: Grey[300] default, Primary when focused

### Border Radius
- Tất cả các widget: 12px

### Padding
- Button: 14px vertical, 24px horizontal
- Input: 16px all sides

### Font
- Button text: 16px, Weight 600
- Input text: 16px, Weight 500
- Label: 16px, Weight 500 (normal), 600 (floating)

## Migration Guide

### Từ ElevatedButton sang AppButton.primary

```dart
// Before
ElevatedButton(
  onPressed: () {},
  child: Text('Save'),
)

// After
AppButton.primary(
  text: 'Save',
  onPressed: () {},
)
```

### Từ TextField sang AppInput

```dart
// Before
TextField(
  controller: controller,
  decoration: InputDecoration(
    labelText: 'Amount',
    prefixIcon: Icon(Icons.money),
    border: OutlineInputBorder(),
  ),
)

// After
AppInput(
  controller: controller,
  labelText: 'Amount',
  prefixIcon: Icons.money,
)
```

## Tips

1. **Consistency**: Luôn sử dụng AppButton và AppInput thay vì Flutter default widgets
2. **Width**: Sử dụng `width: double.infinity` cho full-width buttons
3. **Loading**: Sử dụng `isLoading: true` thay vì hiển thị CircularProgressIndicator riêng
4. **Icons**: Thêm icon để buttons và inputs dễ hiểu hơn
5. **Validation**: Luôn validate input trong Form

## Maintenance

Nếu cần điều chỉnh design system:
- Colors: Sửa trong `_getButtonStyle()` và `_getLoadingColor()` của AppButton
- Spacing: Sửa `contentPadding` trong các widget
- Border radius: Tìm `BorderRadius.circular(12)` và thay đổi
- Font sizes: Tìm `fontSize:` trong code
