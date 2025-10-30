## 🧪 Testing Instructions: Icon Display Fix

### Prerequisites
```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Test Scenarios

#### ✅ Test 1: Dashboard Icons
**Steps:**
1. Launch app and navigate to Dashboard
2. Check Pie Chart - each category slice should have icon + name
3. Check Bar Chart - monthly view should display correctly
4. Check summary cards with transaction preview

**Expected:** 
- Icons visible in Pie Chart legend (utensils, car, shopping bag, etc.)
- Icons in recent transaction list on dashboard

---

#### ✅ Test 2: Transaction List Icons
**Steps:**
1. From Dashboard, tap "Danh sách giao dịch" icon
2. Verify each transaction card shows:
   - Category icon (colored circle background)
   - Category name
   - Transaction description
   - Amount with color

**Expected:** 
- All 12 mock transactions display proper FontAwesome icons
- Icons match their categories (food→utensils, transport→car, etc.)

---

#### ✅ Test 3: Add Transaction with Icon
**Steps:**
1. Tap FAB "+" button on Transaction List
2. Select category from dropdown
3. Each dropdown item should show icon + name
4. Fill form and save
5. Return to list - verify new transaction shows correct icon

**Expected:** 
- Dropdown shows all categories with icons
- New transaction card displays selected category icon

---

#### ✅ Test 4: Category List Icons  
**Steps:**
1. From Dashboard, tap "Quản lý nhóm" icon (category_outlined)
2. Grid view should show 3 columns of category cards
3. Each card displays:
   - Large icon with colored background
   - Category name
   - Type badge (Thu/Chi/Cả hai)

**Expected:** 
- All 10 mock categories visible with proper FontAwesome icons
- Icon colors match category colors
- Grid layout displays correctly

---

#### ✅ Test 5: Add Category with Icon Picker
**Steps:**
1. On Category List, tap FAB "+"
2. Tap "Chọn icon" button
3. Icon picker dialog shows 36 FontAwesome icons in 4-column grid
4. Select an icon (e.g., gamepad)
5. Verify preview card updates immediately with selected icon
6. Select color from color picker
7. Enter name and save
8. Return to list - verify new category displays correctly

**Expected:** 
- Icon picker shows all 36 icons properly rendered
- Preview updates in real-time
- Saved category persists icon correctly

---

#### ✅ Test 6: Edit Category Icon
**Steps:**
1. Long-press any category card in Category List
2. OR tap card to edit
3. Current icon should display in form
4. Change icon via icon picker
5. Save changes
6. Verify updated icon appears everywhere (list, transactions, dashboard)

**Expected:** 
- Icon persists across app restart
- Icon updates propagate to all related transactions

---

#### ✅ Test 7: Icon Persistence (Critical)
**Steps:**
1. Add a new category with custom icon + color
2. Add 2-3 transactions using this category
3. **Hot restart app** (not hot reload)
4. Navigate to Dashboard → Transaction List → Category List
5. Verify icon appears consistently everywhere

**Expected:** 
- Icons load correctly after app restart
- No placeholder icons or missing icons
- All previous data intact

---

### Console Output to Verify

On **first launch after update**, you should see:
```
🔄 Migrating category data to new schema with iconFontPackage...
✅ Mock data initialized with proper icon support
```

On **subsequent launches** (no migration needed):
```
# No migration messages - data loads normally
```

---

### Debugging Tips

**If icons don't appear:**
1. Check console for errors about missing fonts
2. Verify `pubspec.yaml` includes `font_awesome_flutter: ^10.7.0`
3. Run `flutter clean && flutter pub get`
4. Hard restart app (not hot reload)
5. Check Hive data: Delete app and reinstall to force fresh migration

**If only some icons appear:**
- Check if Material icons work but FontAwesome don't → fontPackage issue
- Check if icons in one screen work but not others → check entity/model conversion

**If migration doesn't trigger:**
- Add breakpoint in `injection_container.dart` at line with `needsMigration`
- Debug and verify `firstCategory.iconFontPackage` is null for old data
- Manually clear app data to force migration

---

### Expected Icon Mapping

| Category ID | Icon | FontFamily | Package |
|------------|------|------------|---------|
| food | utensils | FontAwesomeSolid | font_awesome_flutter |
| transport | car | FontAwesomeSolid | font_awesome_flutter |
| shopping | shoppingBag | FontAwesomeSolid | font_awesome_flutter |
| entertainment | gamepad | FontAwesomeSolid | font_awesome_flutter |
| health | heartPulse | FontAwesomeSolid | font_awesome_flutter |
| education | graduationCap | FontAwesomeSolid | font_awesome_flutter |
| other | ellipsis | FontAwesomeSolid | font_awesome_flutter |
| salary | moneyBill | FontAwesomeSolid | font_awesome_flutter |
| bonus | gift | FontAwesomeSolid | font_awesome_flutter |
| investment | chartLine | FontAwesomeSolid | font_awesome_flutter |

All icons should render with proper styling and color.
