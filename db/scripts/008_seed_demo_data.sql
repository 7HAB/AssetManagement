/* ============================================================================
   008_seed_demo_data.sql
   Demo data so the app (and the AI questions in R4) have something to show:
     categories, asset types, manufacturers, currencies, departments,
     locations, employees, 14 assets and their history.

   Chosen to exercise the brief's example questions:
     "laptops assigned to Presales"  -> AST-0001, AST-0002
     "which assets are available"    -> AST-0004, AST-0010, AST-0012
     "how many Dell laptops"         -> 4 (AST-0001, 0002, 0003, 0013)
     "assets assigned to Ahmed"      -> TWO Ahmeds on purpose (E001, E006),
                                        so the AI must ask which one
   Also covers: an asset with no cost and no serial (AST-0010), Under
   Maintenance keeping its holder (AST-0005), a Retired asset (AST-0008),
   department-only assignments (AST-0006, AST-0011), two currencies.

   Every row is created by the System user (AppUserId 1, from 007).
   Lookup IDs are never hard-coded: rows are matched by their natural key
   (NameEn, Code, EmployeeNumber, AssetCode), so IDENTITY values don't matter.

   History is consistent with each asset's current state:
     - every asset gets an Initial event,
     - some get a second event (Transfer or Status Change) that leads from the
       initial state to the current one.

   Re-runnable: inserts only what is missing. One transaction.
   Requires: 000-005 and 007.
   ============================================================================ */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
SET NOCOUNT ON;
GO

USE AssetManagement;
GO

-- Guard inside the same batch as the inserts, so a missing System user stops
-- everything (a GO in between would let SSMS carry on with the next batch).
IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE AppUserId = 1)
    THROW 50002, N'System user (AppUserId 1) is missing. Run 007_seed_reference_data.sql first.', 1;

BEGIN TRANSACTION;

DECLARE @System int = 1;

/* ---- Categories ------------------------------------------------------------------- */

INSERT INTO dbo.Category (NameEn, NameAr, CreatedBy)
SELECT v.NameEn, v.NameAr, @System
FROM (VALUES
        (N'Computers',      N'أجهزة الحاسوب'),
        (N'Peripherals',    N'الملحقات'),
        (N'Mobile Devices', N'الأجهزة المحمولة'),
        (N'Networking',     N'معدات الشبكات')
     ) AS v (NameEn, NameAr)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Category c WHERE c.NameEn = v.NameEn AND c.IsDeleted = 0);

/* ---- Asset types (each belongs to a category) ------------------------------------- */

INSERT INTO dbo.AssetType (CategoryId, NameEn, NameAr, CreatedBy)
SELECT c.CategoryId, v.NameEn, v.NameAr, @System
FROM (VALUES
        (N'Computers',      N'Laptop',  N'حاسوب محمول'),
        (N'Computers',      N'Desktop', N'حاسوب مكتبي'),
        (N'Peripherals',    N'Monitor', N'شاشة'),
        (N'Peripherals',    N'Printer', N'طابعة'),
        (N'Mobile Devices', N'Phone',   N'هاتف'),
        (N'Mobile Devices', N'Tablet',  N'جهاز لوحي'),
        (N'Networking',     N'Switch',  N'محوّل شبكة')
     ) AS v (CategoryNameEn, NameEn, NameAr)
JOIN dbo.Category c ON c.NameEn = v.CategoryNameEn AND c.IsDeleted = 0
WHERE NOT EXISTS (SELECT 1 FROM dbo.AssetType t WHERE t.NameEn = v.NameEn AND t.IsDeleted = 0);

/* ---- Manufacturers ---------------------------------------------------------------- */

INSERT INTO dbo.Manufacturer (NameEn, NameAr, CreatedBy)
SELECT v.NameEn, v.NameAr, @System
FROM (VALUES
        (N'Dell',    N'ديل'),
        (N'HP',      N'إتش بي'),
        (N'Lenovo',  N'لينوفو'),
        (N'Apple',   N'أبل'),
        (N'Samsung', N'سامسونج'),
        (N'Cisco',   N'سيسكو')
     ) AS v (NameEn, NameAr)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Manufacturer m WHERE m.NameEn = v.NameEn AND m.IsDeleted = 0);

/* ---- Currencies ------------------------------------------------------------------- */

INSERT INTO dbo.Currency (Code, NameEn, NameAr, CreatedBy)
SELECT v.Code, v.NameEn, v.NameAr, @System
FROM (VALUES
        ('EGP', N'Egyptian Pound', N'جنيه مصري'),
        ('USD', N'US Dollar',      N'دولار أمريكي')
     ) AS v (Code, NameEn, NameAr)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Currency c WHERE c.Code = v.Code AND c.IsDeleted = 0);

/* ---- Departments ------------------------------------------------------------------ */

INSERT INTO dbo.Department (NameEn, NameAr, CreatedBy)
SELECT v.NameEn, v.NameAr, @System
FROM (VALUES
        (N'Presales',        N'ما قبل البيع'),
        (N'Engineering',     N'الهندسة'),
        (N'Finance',         N'المالية'),
        (N'Human Resources', N'الموارد البشرية'),
        (N'IT Operations',   N'عمليات تقنية المعلومات')
     ) AS v (NameEn, NameAr)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Department d WHERE d.NameEn = v.NameEn AND d.IsDeleted = 0);

/* ---- Locations -------------------------------------------------------------------- */

INSERT INTO dbo.Location (NameEn, NameAr, CreatedBy)
SELECT v.NameEn, v.NameAr, @System
FROM (VALUES
        (N'Cairo HQ',             N'المقر الرئيسي - القاهرة'),
        (N'Alexandria Office',    N'مكتب الإسكندرية'),
        (N'Smart Village Office', N'مكتب القرية الذكية'),
        (N'Central Warehouse',    N'المخزن المركزي')
     ) AS v (NameEn, NameAr)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Location l WHERE l.NameEn = v.NameEn AND l.IsDeleted = 0);

/* ---- Employees -------------------------------------------------------------------- */

INSERT INTO dbo.Employee (EmployeeNumber, FirstNameEn, LastNameEn, FirstNameAr, LastNameAr, DepartmentId, CreatedBy)
SELECT v.EmployeeNumber, v.FirstNameEn, v.LastNameEn, v.FirstNameAr, v.LastNameAr, d.DepartmentId, @System
FROM (VALUES
        (N'E001', N'Ahmed',  N'Hassan',  N'أحمد',  N'حسن',   N'Presales'),
        (N'E002', N'Mona',   N'Adel',    N'منى',   N'عادل',  N'Presales'),
        (N'E003', N'Omar',   N'Khaled',  N'عمر',   N'خالد',  N'Engineering'),
        (N'E004', N'Sara',   N'Mahmoud', N'سارة',  N'محمود', N'Finance'),
        (N'E005', N'Youssef',N'Ali',     N'يوسف',  N'علي',   N'IT Operations'),
        (N'E006', N'Ahmed',  N'Samir',   N'أحمد',  N'سمير',  N'Engineering')
     ) AS v (EmployeeNumber, FirstNameEn, LastNameEn, FirstNameAr, LastNameAr, DepartmentNameEn)
JOIN dbo.Department d ON d.NameEn = v.DepartmentNameEn AND d.IsDeleted = 0
WHERE NOT EXISTS (SELECT 1 FROM dbo.Employee e WHERE e.EmployeeNumber = v.EmployeeNumber AND e.IsDeleted = 0);

/* ---- Assets: one working table describing current state + history ----------------- */

-- Status IDs: 1 Available, 2 Assigned, 3 Under Maintenance, 4 Retired
-- Event IDs:  2 Transfer, 3 Status Change (Initial = 1 is always written)
-- Init* columns are only used when there is a second event; otherwise the
-- Initial event goes straight to the current state.
-- Temp tables live in tempdb, which uses the SERVER's collation, not this
-- database's. COLLATE DATABASE_DEFAULT makes the text columns use the
-- database collation, so joins to dbo tables don't fail with a collation conflict.
CREATE TABLE #DemoAsset
(
    AssetCode      nvarchar(50) COLLATE DATABASE_DEFAULT   NOT NULL,
    AssetName      nvarchar(150) COLLATE DATABASE_DEFAULT  NOT NULL,
    TypeName       nvarchar(100) COLLATE DATABASE_DEFAULT  NOT NULL,
    Manufacturer   nvarchar(100) COLLATE DATABASE_DEFAULT  NULL,
    Model          nvarchar(100) COLLATE DATABASE_DEFAULT  NULL,
    SerialNumber   nvarchar(100) COLLATE DATABASE_DEFAULT  NULL,
    PurchaseDate   date           NULL,
    PurchaseCost   decimal(18, 2) NULL,
    CurrencyCode   char(3) COLLATE DATABASE_DEFAULT        NULL,
    WarrantyYears  int            NULL,
    -- current state
    StatusId       int            NOT NULL,
    EmployeeNumber nvarchar(20) COLLATE DATABASE_DEFAULT   NULL,
    DepartmentName nvarchar(100) COLLATE DATABASE_DEFAULT  NULL,
    LocationName   nvarchar(100) COLLATE DATABASE_DEFAULT  NOT NULL,
    -- initial event
    InitDate       date           NOT NULL,
    InitStatusId   int            NULL,
    InitEmployee   nvarchar(20) COLLATE DATABASE_DEFAULT   NULL,
    InitDepartment nvarchar(100) COLLATE DATABASE_DEFAULT  NULL,
    InitLocation   nvarchar(100) COLLATE DATABASE_DEFAULT  NULL,
    -- optional second event (leads from the initial state to the current state)
    Event2TypeId   int            NULL,
    Event2Date     date           NULL,
    Event2Reason   nvarchar(500) COLLATE DATABASE_DEFAULT  NULL
);

INSERT INTO #DemoAsset VALUES
-- code        name                         type       maker      model                serial            bought        cost      cur   wty  | now: st  emp     dept               location                | init date    st    emp     dept               location             | event2 type, date, reason
(N'AST-0001', N'Dell Latitude 5440',       N'Laptop',  N'Dell',    N'Latitude 5440',    N'DL5440-0001',   '2025-01-15', 45000.00, 'EGP', 3,    2, N'E001', N'Presales',        N'Cairo HQ',             '2025-01-20', 1,    NULL,   NULL,              N'Central Warehouse', 2, '2025-02-01', N'Equipment for new hire'),
(N'AST-0002', N'Dell Latitude 5440',       N'Laptop',  N'Dell',    N'Latitude 5440',    N'DL5440-0002',   '2025-01-15', 45000.00, 'EGP', 3,    2, N'E002', N'Presales',        N'Cairo HQ',             '2025-01-20', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL),
(N'AST-0003', N'Dell XPS 13',              N'Laptop',  N'Dell',    N'XPS 13 9340',      N'DLXPS-1340',    '2024-06-10',  1450.00, 'USD', 2,    2, N'E003', N'Engineering',     N'Smart Village Office', '2024-06-15', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL),
(N'AST-0004', N'Lenovo ThinkPad T14',      N'Laptop',  N'Lenovo',  N'ThinkPad T14 Gen 4',N'LNT14-0004',   '2024-09-01', 38000.00, 'EGP', 3,    1, NULL,    NULL,               N'Central Warehouse',    '2024-09-05', 2,    N'E004', N'Finance',        N'Cairo HQ',          2, '2025-06-30', N'Returned to stock after role change'),
(N'AST-0005', N'HP EliteBook 840',         N'Laptop',  N'HP',      N'EliteBook 840 G10',N'HPEB-0840',     '2023-11-20', 32000.00, 'EGP', 3,    3, N'E006', N'Engineering',     N'Cairo HQ',             '2023-11-25', 2,    N'E006', N'Engineering',    N'Cairo HQ',          3, '2026-10-20', N'Battery replacement'),
(N'AST-0006', N'Dell OptiPlex 7010',       N'Desktop', N'Dell',    N'OptiPlex 7010',    N'DLOP-7010',     '2024-03-01', 28000.00, 'EGP', 3,    2, NULL,    N'Finance',         N'Cairo HQ',             '2024-03-05', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL),
(N'AST-0007', N'Dell 27 USB-C Monitor',    N'Monitor', N'Dell',    N'P2723DE',          N'DLP27-0007',    '2024-03-01',  9500.00, 'EGP', 3,    2, N'E001', N'Presales',        N'Cairo HQ',             '2024-03-05', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL),
(N'AST-0008', N'HP LaserJet Pro',          N'Printer', N'HP',      N'LaserJet Pro M404',N'HPLJ-0404',     '2022-05-10', 12000.00, 'EGP', 1,    4, NULL,    NULL,               N'Cairo HQ',             '2022-05-15', 2,    NULL,   N'Human Resources', N'Cairo HQ',          3, '2026-09-01', N'End of life, replaced'),
(N'AST-0009', N'Apple iPhone 15',          N'Phone',   N'Apple',   N'iPhone 15',        N'APIP15-0009',   '2025-03-10',  1100.00, 'USD', 1,    2, N'E002', N'Presales',        N'Cairo HQ',             '2025-03-12', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL),
(N'AST-0010', N'Samsung Galaxy Tab S9',    N'Tablet',  N'Samsung', N'Galaxy Tab S9',    NULL,             '2025-02-01',     NULL, NULL,  NULL, 1, NULL,    NULL,               N'Central Warehouse',    '2025-02-03', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL),
(N'AST-0011', N'Cisco Catalyst 9200',      N'Switch',  N'Cisco',   N'Catalyst 9200-24T',N'CSC9200-0011',  '2023-07-01',  4200.00, 'USD', 5,    2, NULL,    N'IT Operations',   N'Smart Village Office', '2023-07-05', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL),
(N'AST-0012', N'Lenovo ThinkPad X1 Carbon',N'Laptop',  N'Lenovo',  N'X1 Carbon Gen 12', N'LNX1-0012',     '2025-08-01', 70000.00, 'EGP', 3,    1, NULL,    NULL,               N'Alexandria Office',    '2025-08-03', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL),
(N'AST-0013', N'Dell Latitude 7450',       N'Laptop',  N'Dell',    N'Latitude 7450',    N'DL7450-0013',   '2026-01-10', 62000.00, 'EGP', 3,    2, N'E005', N'IT Operations',   N'Cairo HQ',             '2026-01-12', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL),
(N'AST-0014', N'Apple MacBook Pro 14',     N'Laptop',  N'Apple',   N'MacBook Pro 14 M4',N'APMBP-0014',    '2025-05-05',  2400.00, 'USD', 1,    2, N'E006', N'Engineering',     N'Smart Village Office', '2025-05-07', NULL, NULL,   NULL,              NULL,                 NULL, NULL, NULL);

/* ---- Insert missing assets (current state) ------------------------------------------- */

INSERT INTO dbo.Asset
    (AssetCode, AssetName, AssetTypeId, ManufacturerId, Model, SerialNumber,
     PurchaseDate, PurchaseCost, CurrencyId, WarrantyExpiryDate,
     StatusId, AssignedEmployeeId, DepartmentId, LocationId, CreatedBy)
SELECT
     a.AssetCode, a.AssetName, t.AssetTypeId, m.ManufacturerId, a.Model, a.SerialNumber,
     a.PurchaseDate, a.PurchaseCost, cur.CurrencyId, DATEADD(YEAR, a.WarrantyYears, a.PurchaseDate),
     a.StatusId, e.EmployeeId, d.DepartmentId, l.LocationId, @System
FROM #DemoAsset a
JOIN      dbo.AssetType    t   ON t.NameEn         = a.TypeName       AND t.IsDeleted   = 0
LEFT JOIN dbo.Manufacturer m   ON m.NameEn         = a.Manufacturer   AND m.IsDeleted   = 0
LEFT JOIN dbo.Currency     cur ON cur.Code         = a.CurrencyCode   AND cur.IsDeleted = 0
LEFT JOIN dbo.Employee     e   ON e.EmployeeNumber = a.EmployeeNumber AND e.IsDeleted   = 0
LEFT JOIN dbo.Department   d   ON d.NameEn         = a.DepartmentName AND d.IsDeleted   = 0
JOIN      dbo.Location     l   ON l.NameEn         = a.LocationName   AND l.IsDeleted   = 0
WHERE NOT EXISTS (SELECT 1 FROM dbo.Asset x WHERE x.AssetCode = a.AssetCode AND x.IsDeleted = 0);

/* ---- History: Initial event for assets that have no history yet --------------------- */

-- Without a second event, the Initial event leads straight to the current state.
INSERT INTO dbo.AssetHistory
    (AssetId, EventTypeId,
     FromStatusId, ToStatusId,
     FromEmployeeId, ToEmployeeId,
     FromDepartmentId, ToDepartmentId,
     FromLocationId, ToLocationId,
     EffectiveDate, Reason, PerformedBy)
SELECT
     x.AssetId, 1,
     NULL, CASE WHEN a.Event2TypeId IS NULL THEN a.StatusId ELSE a.InitStatusId END,
     NULL, ie.EmployeeId,
     NULL, idp.DepartmentId,
     NULL, il.LocationId,
     a.InitDate, NULL, @System
FROM #DemoAsset a
JOIN dbo.Asset x ON x.AssetCode = a.AssetCode AND x.IsDeleted = 0
LEFT JOIN dbo.Employee   ie  ON ie.EmployeeNumber = CASE WHEN a.Event2TypeId IS NULL THEN a.EmployeeNumber ELSE a.InitEmployee   END AND ie.IsDeleted  = 0
LEFT JOIN dbo.Department idp ON idp.NameEn        = CASE WHEN a.Event2TypeId IS NULL THEN a.DepartmentName ELSE a.InitDepartment END AND idp.IsDeleted = 0
JOIN      dbo.Location   il  ON il.NameEn         = CASE WHEN a.Event2TypeId IS NULL THEN a.LocationName   ELSE a.InitLocation   END AND il.IsDeleted  = 0
WHERE NOT EXISTS (SELECT 1 FROM dbo.AssetHistory h WHERE h.AssetId = x.AssetId);

/* ---- History: second event (from the initial state to the current state) ------------ */

INSERT INTO dbo.AssetHistory
    (AssetId, EventTypeId,
     FromStatusId, ToStatusId,
     FromEmployeeId, ToEmployeeId,
     FromDepartmentId, ToDepartmentId,
     FromLocationId, ToLocationId,
     EffectiveDate, Reason, PerformedBy)
SELECT
     x.AssetId, a.Event2TypeId,
     a.InitStatusId, a.StatusId,
     ie.EmployeeId, x.AssignedEmployeeId,
     idp.DepartmentId, x.DepartmentId,
     il.LocationId, x.LocationId,
     a.Event2Date, a.Event2Reason, @System
FROM #DemoAsset a
JOIN dbo.Asset x ON x.AssetCode = a.AssetCode AND x.IsDeleted = 0
LEFT JOIN dbo.Employee   ie  ON ie.EmployeeNumber = a.InitEmployee   AND ie.IsDeleted  = 0
LEFT JOIN dbo.Department idp ON idp.NameEn        = a.InitDepartment AND idp.IsDeleted = 0
JOIN      dbo.Location   il  ON il.NameEn         = a.InitLocation   AND il.IsDeleted  = 0
WHERE a.Event2TypeId IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.AssetHistory h WHERE h.AssetId = x.AssetId AND h.EventTypeId <> 1);

DROP TABLE #DemoAsset;

COMMIT TRANSACTION;
GO
