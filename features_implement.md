# 📋 Danh Sách Chức Năng Cần Phát Triển

## Tình Trạng Hiện Tại

### ✅ Đã Hoàn Thành

1. **Dashboard** - Tổng quan tài chính
   - Hiển thị tổng thu/chi/số dư
   - Biểu đồ tròn chi tiêu/thu nhập theo nhóm
   - Biểu đồ cột theo tháng
   - Bộ lọc thời gian

2. **Category Management** - Quản lý nhóm chi tiêu
   - CRUD đầy đủ (Create, Read, Update, Delete)
   - Chọn icon Font Awesome
   - Chọn màu sắc
   - Phân loại thu/chi

3. **Transaction Management** - Quản lý giao dịch
   - CRUD đầy đủ
   - Filter theo loại (thu/chi/tất cả)
   - Format số tiền
   - Chọn ngày

4. **Statistics** - Thống kê phân tích
   - Thống kê theo nhóm category
   - Thống kê theo thời gian (ngày/tháng/năm/khoảng)
   - Biểu đồ tròn và biểu đồ cột
   - Bộ lọc nâng cao

---

## 🎯 Các Chức Năng Cần Phát Triển (Theo Mức Độ Ưu Tiên)

### **Mức 1: CAO - Tính Năng Cốt Lõi Thiết Yếu**

#### 1. 💰 **Budget Management - Quản Lý Ngân Sách**
**Độ ưu tiên:** ⭐⭐⭐⭐⭐

**Mô tả:**
- Thiết lập ngân sách theo từng category (theo tháng/quý/năm)
- Theo dõi % ngân sách đã sử dụng
- Cảnh báo khi vượt ngân sách (80%, 100%, 120%)
- Biểu đồ progress bar cho mỗi category
- So sánh thực tế vs ngân sách theo thời gian

**Lý do ưu tiên cao:**
- Kết nối trực tiếp với Categories + Transactions + Statistics
- Tạo giá trị tức thì cho người dùng
- Tăng engagement và retention
- Là tính năng quan trọng nhất của app quản lý tài chính

**Kỹ thuật:**
- Entity: BudgetEntity (categoryId, amount, period, startDate, endDate)
- UseCase: SetBudget, GetBudget, CheckBudgetStatus
- Repository: BudgetRepository (Hive storage)
- Presentation: BudgetManagementPage, BudgetProgressWidget, BudgetAlertDialog

**Thời gian dự kiến:** 5-7 ngày

---

#### 2. 🔄 **Recurring Transactions - Giao Dịch Định Kỳ**
**Độ ưu tiên:** ⭐⭐⭐⭐⭐

**Mô tả:**
- Tạo giao dịch lặp lại theo chu kỳ (hàng ngày/tuần/tháng/năm)
- Tự động tạo transaction vào ngày đến hạn
- Quản lý danh sách giao dịch định kỳ
- Tạm dừng/tiếp tục/xóa giao dịch định kỳ
- Notification nhắc nhở trước ngày đến hạn

**Lý do ưu tiên cao:**
- Giảm công nhập liệu cho người dùng (lương, tiền nhà, hóa đơn...)
- Là nền tảng cho tính năng dự báo dòng tiền
- Tăng tính tự động hóa của app

**Kỹ thuật:**
- Entity: RecurringTransactionEntity (frequency, nextDate, endDate, isActive)
- UseCase: CreateRecurring, GeneratePendingTransactions, UpdateRecurring
- Background Service: Cron job để tạo transactions tự động
- Repository: RecurringTransactionRepository

**Thời gian dự kiến:** 5-7 ngày

---

#### 3. 💾 **Backup & Restore - Sao Lưu & Khôi Phục**
**Độ ưu tiên:** ⭐⭐⭐⭐⭐

**Mô tả:**
- Export dữ liệu ra file (JSON/Excel/CSV)
- Import dữ liệu từ file
- Backup tự động định kỳ
- Lưu backup lên cloud (Google Drive/Dropbox) - Optional
- Khôi phục dữ liệu từ backup

**Lý do ưu tiên cao:**
- Đảm bảo an toàn dữ liệu người dùng
- Tăng niềm tin sử dụng app
- Hỗ trợ chuyển đổi thiết bị
- Dễ chia sẻ dữ liệu với accountant/gia đình

**Kỹ thuật:**
- UseCase: ExportData, ImportData, AutoBackup
- File Handling: path_provider, file_picker
- Cloud Storage: firebase_storage (optional)
- Data Format: JSON (structure preservation)

**Thời gian dự kiến:** 4-5 ngày

---

### **Mức 2: TRUNG BÌNH - Tính Năng Nâng Cao Trải Nghiệm**

#### 4. 🔍 **Advanced Search & Filter - Tìm Kiếm Nâng Cao**
**Độ ưu tiên:** ⭐⭐⭐⭐

**Mô tả:**
- Tìm kiếm transaction theo từ khóa (description)
- Filter đa điều kiện (category, amount range, date range)
- Sort theo nhiều tiêu chí (date, amount, category)
- Lưu bộ lọc thường dùng (saved filters)
- Full-text search

**Lý do:**
- Cải thiện UX khi có nhiều giao dịch
- Dễ dàng tra cứu giao dịch cũ
- Hỗ trợ phân tích chi tiết

**Kỹ thuật:**
- UseCase: SearchTransactions, SaveFilter
- UI: SearchDelegate, AdvancedFilterBottomSheet
- Optimization: Indexing cho search performance

**Thời gian dự kiến:** 3-4 ngày

---

#### 5. 🎯 **Financial Goals - Mục Tiêu Tài Chính**
**Độ ưu tiên:** ⭐⭐⭐⭐

**Mô tả:**
- Đặt mục tiêu tiết kiệm (mua nhà, du lịch, mua xe...)
- Theo dõi progress đạt được
- Tự động tính toán số tiền cần tiết kiệm mỗi tháng
- Liên kết với transactions (tag transaction cho goal)
- Biểu đồ tiến độ đạt mục tiêu

**Lý do:**
- Tạo động lực tiết kiệm cho người dùng
- Tăng tính gắn kết với app
- Gamification element

**Kỹ thuật:**
- Entity: FinancialGoalEntity (name, targetAmount, currentAmount, deadline)
- UseCase: CreateGoal, UpdateProgress, CalculateMonthlyTarget
- Widget: GoalProgressCard, GoalListView

**Thời gian dự kiến:** 4-5 ngày

---

#### 6. 📊 **Reports & Insights - Báo Cáo & Phân Tích Thông Minh**
**Độ ưu tiên:** ⭐⭐⭐⭐

**Mô tả:**
- Báo cáo tháng/quý/năm (PDF export)
- Phân tích xu hướng chi tiêu (tăng/giảm theo thời gian)
- So sánh tháng này vs tháng trước
- AI insights: "Chi tiêu cho ăn uống tăng 30% so với tháng trước"
- Top spending categories
- Unusual spending alerts

**Lý do:**
- Cung cấp giá trị insights cho người dùng
- Tạo sự khác biệt với competitors
- Hỗ trợ ra quyết định tài chính tốt hơn

**Kỹ thuật:**
- UseCase: GenerateReport, CalculateTrends, DetectAnomalies
- PDF Generation: pdf package
- Chart: fl_chart với nhiều loại biểu đồ

**Thời gian dự kiến:** 5-6 ngày

---

#### 7. 🔔 **Notifications & Reminders - Thông Báo & Nhắc Nhở**
**Độ ưu tiên:** ⭐⭐⭐⭐

**Mô tả:**
- Nhắc nhở nhập giao dịch hàng ngày
- Nhắc nhở trước khi giao dịch định kỳ đến hạn
- Thông báo vượt ngân sách
- Báo cáo tóm tắt cuối tháng
- Customizable notification settings

**Lý do:**
- Tăng habit formation
- Giảm missing data
- Tăng engagement

**Kỹ thuật:**
- Package: flutter_local_notifications
- UseCase: ScheduleNotification, CancelNotification
- Background: WorkManager for periodic checks

**Thời gian dự kiến:** 3-4 ngày

---

### **Mức 3: THẤP - Tính Năng Bổ Sung & Tối Ưu**

#### 8. 🏦 **Multi-Account Support - Hỗ Trợ Nhiều Tài Khoản**
**Độ ưu tiên:** ⭐⭐⭐

**Mô tả:**
- Quản lý nhiều tài khoản (tiền mặt, ngân hàng, ví điện tử)
- Chuyển khoản giữa các tài khoản
- Xem số dư từng tài khoản
- Filter transactions theo account
- Account reconciliation

**Lý do:**
- Phù hợp với người dùng có nhiều nguồn tiền
- Tăng tính chuyên nghiệp của app
- Theo dõi được money flow chính xác hơn

**Kỹ thuật:**
- Entity: AccountEntity (name, type, balance, currency)
- Update TransactionEntity: thêm accountId, transferTo
- UseCase: TransferBetweenAccounts, ReconcileAccount

**Thời gian dự kiến:** 5-6 ngày

---

#### 9. 💱 **Multi-Currency Support - Hỗ Trợ Nhiều Loại Tiền Tệ**
**Độ ưu tiên:** ⭐⭐⭐

**Mô tả:**
- Thêm transactions với nhiều loại tiền tệ
- Tự động convert về tiền tệ chính (VND)
- Tích hợp API tỷ giá thực
- Cập nhật tỷ giá định kỳ
- Hiển thị số dư theo nhiều tiền tệ

**Lý do:**
- Phục vụ người dùng đi du lịch/làm việc quốc tế
- Mở rộng thị trường

**Kỹ thuật:**
- API: exchangerate-api.com hoặc fixer.io
- Entity: Currency, ExchangeRate
- UseCase: ConvertCurrency, UpdateExchangeRates

**Thời gian dự kiến:** 4-5 ngày

---

#### 10. 📸 **Receipt Scanner - Quét Hóa Đơn**
**Độ ưu tiên:** ⭐⭐⭐

**Mô tả:**
- Chụp ảnh hóa đơn
- OCR để trích xuất số tiền, ngày, merchant
- Tự động tạo transaction từ hóa đơn
- Lưu trữ ảnh hóa đơn kèm transaction
- Gallery hóa đơn

**Lý do:**
- Giảm thời gian nhập liệu
- Tăng accuracy
- Hỗ trợ kê khai thuế

**Kỹ thuật:**
- Package: google_ml_kit, image_picker
- OCR: Text Recognition
- Storage: Hive + local files

**Thời gian dự kiến:** 6-7 ngày

---

#### 11. 👥 **User Authentication & Cloud Sync - Đăng Nhập & Đồng Bộ**
**Độ ưu tiên:** ⭐⭐⭐

**Mô tả:**
- Đăng ký/đăng nhập tài khoản
- Đồng bộ dữ liệu lên cloud
- Sync giữa nhiều thiết bị
- Shared accounts (gia đình)
- Bảo mật dữ liệu

**Lý do:**
- Tăng retention qua cross-device
- Mở đường cho premium features
- Data safety

**Kỹ thuật:**
- Backend: Firebase Auth + Firestore
- UseCase: Login, Register, SyncData
- Conflict Resolution: Last-write-wins hoặc versioning

**Thời gian dự kiến:** 7-10 ngày

---

#### 12. 🎨 **Themes & Customization - Giao Diện & Tùy Chỉnh**
**Độ ưu tiên:** ⭐⭐⭐

**Mô tả:**
- Dark mode / Light mode
- Nhiều color themes
- Custom fonts
- Widget customization
- Layout preferences

**Lý do:**
- Cải thiện UX
- Tăng sự hài lòng người dùng
- Personalization

**Kỹ thuật:**
- ThemeData với ThemeCubit
- SharedPreferences để lưu settings
- Dynamic theming

**Thời gian dự kiến:** 3-4 ngày

---

#### 13. 📱 **Widgets & Home Screen - Widget Màn Hình Chính**
**Độ ưu tiên:** ⭐⭐

**Mô tả:**
- Home screen widget hiển thị số dư
- Widget tóm tắt chi tiêu hôm nay
- Quick add transaction từ widget
- Widget biểu đồ mini

**Lý do:**
- Quick access
- Tăng visibility của app
- Convenience

**Kỹ thuật:**
- Package: home_widget
- Platform-specific implementation

**Thời gian dự kiến:** 5-6 ngày

---

#### 14. 🤖 **AI Assistant - Trợ Lý AI**
**Độ ưu tiên:** ⭐⭐

**Mô tả:**
- Chatbot hỗ trợ người dùng
- Tự động phân loại transaction (ML)
- Dự đoán category khi nhập
- Smart suggestions
- Voice input

**Lý do:**
- Differentiation
- Future-proof
- Premium feature potential

**Kỹ thuật:**
- ML: TensorFlow Lite
- NLP: Cloud ML APIs
- Voice: speech_to_text

**Thời gian dự kiến:** 10-15 ngày

---

#### 15. 📲 **Social Features - Tính Năng Xã Hội**
**Độ ưu tiên:** ⭐

**Mô tả:**
- Chia sẻ báo cáo lên social media
- So sánh với bạn bè (anonymous)
- Challenges & achievements
- Community tips

**Lý do:**
- Viral marketing
- Gamification
- Community building

**Kỹ thuật:**
- Share: share_plus
- Social login: OAuth
- Leaderboard system

**Thời gian dự kiến:** 7-10 ngày

---

## 📈 Roadmap Đề Xuất

### **Phase 1: Core Enhancement (2-3 tháng)**
- Budget Management ✅
- Recurring Transactions ✅
- Backup & Restore ✅
- Advanced Search & Filter ✅

### **Phase 2: User Value (2-3 tháng)**
- Financial Goals ✅
- Reports & Insights ✅
- Notifications & Reminders ✅
- Multi-Account Support ✅

### **Phase 3: Expansion (3-4 tháng)**
- Multi-Currency Support ✅
- Receipt Scanner ✅
- User Authentication & Cloud Sync ✅
- Themes & Customization ✅

### **Phase 4: Innovation (3-6 tháng)**
- Widgets & Home Screen ✅
- AI Assistant ✅
- Social Features ✅

---

## 💡 Ghi Chú

### **Nguyên Tắc Phát Triển:**
1. **User-Centric:** Ưu tiên tính năng mang lại giá trị trực tiếp cho người dùng
2. **MVP First:** Phát triển version đơn giản trước, hoàn thiện sau
3. **Data Integrity:** Luôn đảm bảo data consistency và backup
4. **Performance:** Optimize cho smooth experience với large datasets
5. **Clean Architecture:** Duy trì pattern hiện tại cho maintainability

### **Metrics Đánh Giá:**
- User Engagement Rate
- Feature Adoption Rate
- Data Entry Speed
- User Retention
- App Rating & Reviews

---

**Cập nhật lần cuối:** 4 tháng 2, 2026
