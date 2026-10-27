# Cyborg Supermarket — Admin Dashboard & Operations Console (Part 1)

Unified multi-role management console and Windows POS administrative operations system implementing the **CYBORG Dark Theme Design System**.

## 🎨 CYBORG Theme Palette
- **Backgrounds**: Deep Cyber Dark (`#0B0F19`, `#0D1117`, `#0F172A`)
- **Primary Accent & CTAs**: Neon Cyan (`#00F0FF`) with glowing borders & drop shadows
- **Secondary Highlights**: Electric Purple (`#7928CA`, `#8B5CF6`)
- **Typography**: High-Contrast Clean White (`#FFFFFF`, `#F8FAFC`) with Segoe UI / Inter
- **Semantic Colors**: Emerald Green (`#10B981`) for on-time/sufficient stock, Rose (`#F43F5E`) for damaged/low stock/lateness, Amber (`#F59E0B`) for pending approvals.

---

## 🏛️ Directory Architecture in `admin-dashboard/`

```text
admin-dashboard/
├── pubspec.yaml                       # Flutter project configuration
├── server.js                          # Standalone Node.js Web Dashboard server (Port 3001)
├── README.md                          # Documentation
└── lib/
    ├── main.dart                      # Multi-role routing & application shell
    ├── core/
    │   ├── theme/
    │   │   └── app_theme.dart         # CYBORG Theme tokens, gradients & AppDecorations
    │   └── data/
    │       ├── mock_data.dart         # Static product catalog & initial receipts
    │       └── pos_state_manager.dart # Centralized reactive mock state manager
    └── features/
        ├── auth/
        │   └── presentation/pages/
        │       └── global_login_screen.dart # 4-Role selection & credentials screen
        ├── owner/
        │   └── presentation/pages/
        │       └── owner_placeholder_screen.dart # Executive Owner suite preview
        ├── stock_manager/
        │   └── presentation/pages/
        │       └── stock_manager_view.dart # Warehouse approvals & reorder console
        └── manager/
            └── presentation/
                ├── pages/
                │   └── manager_dashboard_screen.dart # 7-tab Manager Control Room
                └── tabs/
                    ├── returns_tab.dart             # Returns & Refunds barcode scanner
                    ├── damaged_goods_tab.dart       # Damaged goods scanner & auto-deduct
                    ├── online_cashiers_tab.dart     # Live active cashiers & sales stats
                    ├── employee_management_tab.dart # Add/edit/remove staff & shifts
                    ├── attendance_tab.dart          # Punch-in logs & calculated lateness
                    ├── inventory_low_stock_tab.dart # Low stock alerts & reorder request
                    └── stock_receiving_tab.dart     # Warehouse receipt & POS restock
```

---

## 🚀 Implemented Modules & Features (Part 1)

### 1. Global Role-Based Login Screen
- Clean main login view split into **4 role selections**:
  1. **Owner**: Direct navigation to Executive Suite preview placeholder.
  2. **Manager**: Access to Store Operations & 7 Management Tabs.
  3. **Cashier**: Access to In-Store POS barcode scan & checkout.
  4. **Stock Manager**: Access to warehouse console & reorder approvals.
- High-tech CYBORG aesthetics with active role selection cards, glowing borders, demo credential shortcuts, and smooth state switching.

### 2. Owner Role (Placeholder)
- Futuristic executive placeholder with crown badge and glow effect.
- Clear indication of Phase 2 preview (Multi-branch P&L, Loss Prevention AI, Vault Audits).
- Dedicated "Switch Role / Back to Login" button.

### 3. Manager Role Dashboard (7 Functional Tabs)
1. **Returns & Refunds Tab**:
   - Barcode scanner simulation UI to register returned items originally sold by cashiers.
   - Input for original receipt number, cashier picker, quantity, and return reason.
   - Saves record into the "Returned Products Registry" with audited refund values.
2. **Damaged Goods Tab**:
   - Barcode scanner UI to register damaged products (leakage, packaging crush, expiry).
   - **Automatically deducts damaged quantity from active cashier POS inventory** in real-time.
   - Live visual indicator displaying POS stock before vs. after deduction.
   - Audit log tracking incidents, quantities deducted, total shrinkage loss in EGP, and logging manager.
3. **Online Cashiers Tab**:
   - Live list of currently active working cashiers (Ahmed Hassan, Sara Ibrahim, Mohamed Ali, Layla Nour).
   - Status indicators (Active, In Transaction, Idle).
   - **Clicking any cashier displays their live sales performance drilldown**:
     - Total Shift Sales (EGP), Cash collected, Visa / Card till, and Average Ticket.
     - Live feed of recent checkout transactions and receipts.
     - Cash drawer audit modal with balance verification.
4. **Employee & Shift Management Tab**:
   - Interactive dialogs to **add new Cashiers and Stock Managers** with phone, national ID, and assigned terminal.
   - Interactive dialog to **edit work schedules and shift assignments** (Morning, Evening, Night, Full Shift).
   - Option to **delete/remove employees** with confirmation prompt.
   - Directory filtering by role (All, Cashiers, Stock Managers) and real-time search.
5. **Attendance Tab**:
   - Logs the exact time an employee punches into their shift.
   - **Calculates & displays a status indicating if they are late**:
     - Compares scheduled shift start against actual punch-in time with 5-minute grace period.
     - Dynamic badges: `On-Time` (Neon Cyan/Emerald) vs. `Late (+X mins)` (Rose/Amber).
     - "Clock-In Employee (Manager Override)" dialog with instant lateness calculation.
6. **Store Inventory & Low Stock Tab**:
   - Displays all store products with live stock synchronized across the system.
   - **Automatically flags "Low Stock" items** with flashing badges based on category thresholds.
   - Next to low stock items: **"Request Stock" button** pre-filling Product Name, Code, and Required Quantity.
   - Dispatches request to Stock Manager with status: **"Pending Approval/Denial"**.
   - Dispatched requests track record table showing real-time approval status.
7. **Stock Receiving Tab**:
   - A form for the manager to log and confirm incoming physical shipments from the warehouse (PO #, supplier, product barcode, quantity, batch #, expiry date).
   - **Once logged here, it immediately increases product stock in the POS system so cashiers can sell it**.
   - Confirmation banner and comprehensive shipment registry.

### 4. Stock Manager Console
- Dedicated console for Stock Manager (Hossam El-Din) to view incoming reorder requests sent by the Store Manager.
- Interactive **Approve** and **Deny** buttons that update the Manager's Low Stock tab status in real-time.

---

## 🏃 Running the Application

### Option A: Flutter Application
```bash
cd admin-dashboard
flutter run
```

### Option B: Node.js Admin Server (Port 3001)
```bash
node admin-dashboard/server.js
# or from root:
npm run start:admin
```
Open [http://localhost:3001](http://localhost:3001) in your browser.
