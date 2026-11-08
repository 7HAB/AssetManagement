/* ============================================================================
   003_create_indexes.sql
   Adds unique indexes (business keys) and supporting indexes (filters, FKs).

   Unique rules
     - Unique indexes on soft-deletable tables are FILTERED to IsDeleted = 0,
       so a deleted row frees its value for reuse. Inactive rows still count
       (IsActive is not part of the filter).
     - Uniqueness is case-insensitive because of the database collation (000).

   Naming
     UX_<Table>_<Columns>  unique index
     IX_<Table>_<Columns>  non-unique index

   Filtered indexes need ANSI_NULLS and QUOTED_IDENTIFIER ON, both when they
   are created and when rows are written. SSMS and EF Core use ON by default.

   Re-runnable: each index is created only if it does not exist yet.
   Requires: 001.
   ============================================================================ */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
SET NOCOUNT ON;
GO

USE AssetManagement;
GO

BEGIN TRANSACTION;

/* ---- Code-owned lookups (no soft delete, so no filter) --------------------- */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AssetStatus') AND name = N'UX_AssetStatus_NameEn')
    CREATE UNIQUE INDEX UX_AssetStatus_NameEn ON dbo.AssetStatus (NameEn);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AssetEventType') AND name = N'UX_AssetEventType_NameEn')
    CREATE UNIQUE INDEX UX_AssetEventType_NameEn ON dbo.AssetEventType (NameEn);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Role') AND name = N'UX_Role_NameEn')
    CREATE UNIQUE INDEX UX_Role_NameEn ON dbo.Role (NameEn);

/* ---- AppUser (never deleted, so no IsDeleted filter) ----------------------- */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AppUser') AND name = N'UX_AppUser_Username')
    CREATE UNIQUE INDEX UX_AppUser_Username ON dbo.AppUser (Username);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AppUser') AND name = N'UX_AppUser_Email')
    CREATE UNIQUE INDEX UX_AppUser_Email ON dbo.AppUser (Email);

-- One login per employee at most; many users have no employee link (NULL).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AppUser') AND name = N'UX_AppUser_EmployeeId')
    CREATE UNIQUE INDEX UX_AppUser_EmployeeId ON dbo.AppUser (EmployeeId)
        WHERE EmployeeId IS NOT NULL;

/* ---- RefreshToken ------------------------------------------------------------ */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.RefreshToken') AND name = N'UX_RefreshToken_TokenHash')
    CREATE UNIQUE INDEX UX_RefreshToken_TokenHash ON dbo.RefreshToken (TokenHash);

-- Used to revoke all tokens of a user (deactivation, logout everywhere).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.RefreshToken') AND name = N'IX_RefreshToken_UserId')
    CREATE INDEX IX_RefreshToken_UserId ON dbo.RefreshToken (UserId);

/* ---- Admin-managed lookups ---------------------------------------------------- */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Category') AND name = N'UX_Category_NameEn')
    CREATE UNIQUE INDEX UX_Category_NameEn ON dbo.Category (NameEn)
        WHERE IsDeleted = 0;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AssetType') AND name = N'UX_AssetType_NameEn')
    CREATE UNIQUE INDEX UX_AssetType_NameEn ON dbo.AssetType (NameEn)
        WHERE IsDeleted = 0;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AssetType') AND name = N'IX_AssetType_CategoryId')
    CREATE INDEX IX_AssetType_CategoryId ON dbo.AssetType (CategoryId);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Manufacturer') AND name = N'UX_Manufacturer_NameEn')
    CREATE UNIQUE INDEX UX_Manufacturer_NameEn ON dbo.Manufacturer (NameEn)
        WHERE IsDeleted = 0;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Currency') AND name = N'UX_Currency_NameEn')
    CREATE UNIQUE INDEX UX_Currency_NameEn ON dbo.Currency (NameEn)
        WHERE IsDeleted = 0;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Currency') AND name = N'UX_Currency_Code')
    CREATE UNIQUE INDEX UX_Currency_Code ON dbo.Currency (Code)
        WHERE IsDeleted = 0;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Department') AND name = N'UX_Department_NameEn')
    CREATE UNIQUE INDEX UX_Department_NameEn ON dbo.Department (NameEn)
        WHERE IsDeleted = 0;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Location') AND name = N'UX_Location_NameEn')
    CREATE UNIQUE INDEX UX_Location_NameEn ON dbo.Location (NameEn)
        WHERE IsDeleted = 0;

/* ---- Employee ------------------------------------------------------------------ */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Employee') AND name = N'UX_Employee_EmployeeNumber')
    CREATE UNIQUE INDEX UX_Employee_EmployeeNumber ON dbo.Employee (EmployeeNumber)
        WHERE IsDeleted = 0;

-- Cascading employee picker (employees of a department).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Employee') AND name = N'IX_Employee_DepartmentId')
    CREATE INDEX IX_Employee_DepartmentId ON dbo.Employee (DepartmentId);

/* ---- Asset ------------------------------------------------------------------------ */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Asset') AND name = N'UX_Asset_AssetCode')
    CREATE UNIQUE INDEX UX_Asset_AssetCode ON dbo.Asset (AssetCode)
        WHERE IsDeleted = 0;

-- Unique only when present: many assets have no serial number.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Asset') AND name = N'UX_Asset_SerialNumber')
    CREATE UNIQUE INDEX UX_Asset_SerialNumber ON dbo.Asset (SerialNumber)
        WHERE IsDeleted = 0 AND SerialNumber IS NOT NULL;

-- Supporting indexes for the list filters (R2.2) and for the FKs.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Asset') AND name = N'IX_Asset_AssetTypeId')
    CREATE INDEX IX_Asset_AssetTypeId ON dbo.Asset (AssetTypeId);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Asset') AND name = N'IX_Asset_StatusId')
    CREATE INDEX IX_Asset_StatusId ON dbo.Asset (StatusId);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Asset') AND name = N'IX_Asset_DepartmentId')
    CREATE INDEX IX_Asset_DepartmentId ON dbo.Asset (DepartmentId);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Asset') AND name = N'IX_Asset_LocationId')
    CREATE INDEX IX_Asset_LocationId ON dbo.Asset (LocationId);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Asset') AND name = N'IX_Asset_ManufacturerId')
    CREATE INDEX IX_Asset_ManufacturerId ON dbo.Asset (ManufacturerId);

-- Serves the "assigned employee" filter and the ON UPDATE CASCADE lookup
-- (find the assets of an employee who changed department).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.Asset') AND name = N'IX_Asset_AssignedEmployeeId_DepartmentId')
    CREATE INDEX IX_Asset_AssignedEmployeeId_DepartmentId ON dbo.Asset (AssignedEmployeeId, DepartmentId);

/* ---- AssetHistory ------------------------------------------------------------------ */

-- An event can be corrected at most once.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AssetHistory') AND name = N'UX_AssetHistory_CorrectsHistoryId')
    CREATE UNIQUE INDEX UX_AssetHistory_CorrectsHistoryId ON dbo.AssetHistory (CorrectsHistoryId)
        WHERE CorrectsHistoryId IS NOT NULL;

-- Timeline of one asset in chronological order (R3.2). AssetHistoryId breaks
-- ties between events on the same date.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.AssetHistory') AND name = N'IX_AssetHistory_AssetId_EffectiveDate')
    CREATE INDEX IX_AssetHistory_AssetId_EffectiveDate ON dbo.AssetHistory (AssetId, EffectiveDate, AssetHistoryId);

COMMIT TRANSACTION;
GO
