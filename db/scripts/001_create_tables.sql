/* ============================================================================
   001_create_tables.sql
   Creates every table with its columns, primary key and defaults.

   NOT in this script (added by later scripts, in this order):
     002 foreign keys
     003 indexes and unique indexes
     004 check constraints
     005 triggers

   One exception: UQ_Employee_EmployeeId_DepartmentId is created here, because
   SQL Server requires the referenced columns of a foreign key to already have
   a unique key, and Asset's composite FK (script 002) points at that pair.

   Re-runnable: each table is created only if it does not exist yet.
   The whole script runs in one transaction; any error rolls everything back.

   Conventions
     - Times are UTC, datetime2(3) (millisecond precision).
     - Business dates (purchase, warranty, effective date) are date.
     - Code-owned lookups (AssetStatus, AssetEventType, Role) use fixed IDs,
       no IDENTITY; their values are mirrored by C# enums.
     - Every constraint and default is explicitly named.
   ============================================================================ */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
SET NOCOUNT ON;
GO

USE AssetManagement;
GO

BEGIN TRANSACTION;

/* ----------------------------------------------------------------------------
   Code-owned lookups (fixed IDs, seeded by script 007)
   ---------------------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.AssetStatus', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AssetStatus
    (
        AssetStatusId   int            NOT NULL,
        NameEn          nvarchar(100)  NOT NULL,
        NameAr          nvarchar(100)  NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,

        CONSTRAINT PK_AssetStatus PRIMARY KEY CLUSTERED (AssetStatusId)
    );
END;

IF OBJECT_ID(N'dbo.AssetEventType', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AssetEventType
    (
        AssetEventTypeId int           NOT NULL,
        NameEn          nvarchar(100)  NOT NULL,
        NameAr          nvarchar(100)  NOT NULL,
        TemplateEn      nvarchar(500)  NOT NULL,   -- display sentence with placeholders
        TemplateAr      nvarchar(500)  NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,

        CONSTRAINT PK_AssetEventType PRIMARY KEY CLUSTERED (AssetEventTypeId)
    );
END;

-- Roles are not editable, so no ModifiedAt/ModifiedBy.
IF OBJECT_ID(N'dbo.Role', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Role
    (
        RoleId          int            NOT NULL,
        NameEn          nvarchar(50)   NOT NULL,
        NameAr          nvarchar(50)   NOT NULL,

        CONSTRAINT PK_Role PRIMARY KEY CLUSTERED (RoleId)
    );
END;

/* ----------------------------------------------------------------------------
   Identity
   ---------------------------------------------------------------------------- */

-- No soft delete: users are never deleted, only deactivated.
-- PasswordHash is NULL only for the System user (AppUserId 1), see script 004.
IF OBJECT_ID(N'dbo.AppUser', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AppUser
    (
        AppUserId       int            NOT NULL IDENTITY(1, 1),
        Username        nvarchar(50)   NOT NULL,
        Email           nvarchar(256)  NOT NULL,
        PasswordHash    nvarchar(500)  NULL,
        RoleId          int            NOT NULL,
        EmployeeId      int            NULL,
        IsActive        bit            NOT NULL CONSTRAINT DF_AppUser_IsActive  DEFAULT (1),
        CreatedAt       datetime2(3)   NOT NULL CONSTRAINT DF_AppUser_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy       int            NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,

        CONSTRAINT PK_AppUser PRIMARY KEY CLUSTERED (AppUserId)
    );
END;

-- TokenHash is the raw 32-byte SHA-256 of the token; the token itself is never stored.
IF OBJECT_ID(N'dbo.RefreshToken', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.RefreshToken
    (
        RefreshTokenId    bigint        NOT NULL IDENTITY(1, 1),
        UserId            int           NOT NULL,
        TokenHash         binary(32)    NOT NULL,
        ExpiresAt         datetime2(3)  NOT NULL,
        CreatedAt         datetime2(3)  NOT NULL CONSTRAINT DF_RefreshToken_CreatedAt DEFAULT (SYSUTCDATETIME()),
        RevokedAt         datetime2(3)  NULL,
        ReplacedByTokenId bigint        NULL,

        CONSTRAINT PK_RefreshToken PRIMARY KEY CLUSTERED (RefreshTokenId)
    );
END;

-- Forgot password. TokenHash is the raw SHA-256 of the token sent in the email
-- link; the token itself is never stored. Single use (UsedAt) and short-lived.
IF OBJECT_ID(N'dbo.PasswordResetToken', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PasswordResetToken
    (
        PasswordResetTokenId bigint        NOT NULL IDENTITY(1, 1),
        UserId               int           NOT NULL,
        TokenHash            binary(32)    NOT NULL,
        ExpiresAt            datetime2(3)  NOT NULL,
        CreatedAt            datetime2(3)  NOT NULL CONSTRAINT DF_PasswordResetToken_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UsedAt               datetime2(3)  NULL,

        CONSTRAINT PK_PasswordResetToken PRIMARY KEY CLUSTERED (PasswordResetTokenId)
    );
END;

/* ----------------------------------------------------------------------------
   Admin-managed lookups (audit + soft delete + IsActive)
   ---------------------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.Category', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Category
    (
        CategoryId      int            NOT NULL IDENTITY(1, 1),
        NameEn          nvarchar(100)  NOT NULL,
        NameAr          nvarchar(100)  NOT NULL,
        IsActive        bit            NOT NULL CONSTRAINT DF_Category_IsActive  DEFAULT (1),
        CreatedAt       datetime2(3)   NOT NULL CONSTRAINT DF_Category_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy       int            NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,
        IsDeleted       bit            NOT NULL CONSTRAINT DF_Category_IsDeleted DEFAULT (0),
        DeletedAt       datetime2(3)   NULL,
        DeletedBy       int            NULL,
        DeleteReason    nvarchar(500)  NULL,

        CONSTRAINT PK_Category PRIMARY KEY CLUSTERED (CategoryId)
    );
END;

IF OBJECT_ID(N'dbo.AssetType', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AssetType
    (
        AssetTypeId     int            NOT NULL IDENTITY(1, 1),
        CategoryId      int            NOT NULL,
        NameEn          nvarchar(100)  NOT NULL,
        NameAr          nvarchar(100)  NOT NULL,
        IsActive        bit            NOT NULL CONSTRAINT DF_AssetType_IsActive  DEFAULT (1),
        CreatedAt       datetime2(3)   NOT NULL CONSTRAINT DF_AssetType_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy       int            NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,
        IsDeleted       bit            NOT NULL CONSTRAINT DF_AssetType_IsDeleted DEFAULT (0),
        DeletedAt       datetime2(3)   NULL,
        DeletedBy       int            NULL,
        DeleteReason    nvarchar(500)  NULL,

        CONSTRAINT PK_AssetType PRIMARY KEY CLUSTERED (AssetTypeId)
    );
END;

IF OBJECT_ID(N'dbo.Manufacturer', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Manufacturer
    (
        ManufacturerId  int            NOT NULL IDENTITY(1, 1),
        NameEn          nvarchar(100)  NOT NULL,
        NameAr          nvarchar(100)  NOT NULL,
        IsActive        bit            NOT NULL CONSTRAINT DF_Manufacturer_IsActive  DEFAULT (1),
        CreatedAt       datetime2(3)   NOT NULL CONSTRAINT DF_Manufacturer_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy       int            NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,
        IsDeleted       bit            NOT NULL CONSTRAINT DF_Manufacturer_IsDeleted DEFAULT (0),
        DeletedAt       datetime2(3)   NULL,
        DeletedBy       int            NULL,
        DeleteReason    nvarchar(500)  NULL,

        CONSTRAINT PK_Manufacturer PRIMARY KEY CLUSTERED (ManufacturerId)
    );
END;

IF OBJECT_ID(N'dbo.Currency', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Currency
    (
        CurrencyId      int            NOT NULL IDENTITY(1, 1),
        Code            char(3)        NOT NULL,   -- ISO 4217, e.g. EGP, USD
        NameEn          nvarchar(100)  NOT NULL,
        NameAr          nvarchar(100)  NOT NULL,
        IsActive        bit            NOT NULL CONSTRAINT DF_Currency_IsActive  DEFAULT (1),
        CreatedAt       datetime2(3)   NOT NULL CONSTRAINT DF_Currency_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy       int            NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,
        IsDeleted       bit            NOT NULL CONSTRAINT DF_Currency_IsDeleted DEFAULT (0),
        DeletedAt       datetime2(3)   NULL,
        DeletedBy       int            NULL,
        DeleteReason    nvarchar(500)  NULL,

        CONSTRAINT PK_Currency PRIMARY KEY CLUSTERED (CurrencyId)
    );
END;

IF OBJECT_ID(N'dbo.Department', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Department
    (
        DepartmentId    int            NOT NULL IDENTITY(1, 1),
        NameEn          nvarchar(100)  NOT NULL,
        NameAr          nvarchar(100)  NOT NULL,
        IsActive        bit            NOT NULL CONSTRAINT DF_Department_IsActive  DEFAULT (1),
        CreatedAt       datetime2(3)   NOT NULL CONSTRAINT DF_Department_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy       int            NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,
        IsDeleted       bit            NOT NULL CONSTRAINT DF_Department_IsDeleted DEFAULT (0),
        DeletedAt       datetime2(3)   NULL,
        DeletedBy       int            NULL,
        DeleteReason    nvarchar(500)  NULL,

        CONSTRAINT PK_Department PRIMARY KEY CLUSTERED (DepartmentId)
    );
END;

IF OBJECT_ID(N'dbo.Location', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Location
    (
        LocationId      int            NOT NULL IDENTITY(1, 1),
        NameEn          nvarchar(100)  NOT NULL,
        NameAr          nvarchar(100)  NOT NULL,
        IsActive        bit            NOT NULL CONSTRAINT DF_Location_IsActive  DEFAULT (1),
        CreatedAt       datetime2(3)   NOT NULL CONSTRAINT DF_Location_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy       int            NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,
        IsDeleted       bit            NOT NULL CONSTRAINT DF_Location_IsDeleted DEFAULT (0),
        DeletedAt       datetime2(3)   NULL,
        DeletedBy       int            NULL,
        DeleteReason    nvarchar(500)  NULL,

        CONSTRAINT PK_Location PRIMARY KEY CLUSTERED (LocationId)
    );
END;

/* ----------------------------------------------------------------------------
   Employee
   ---------------------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.Employee', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Employee
    (
        EmployeeId      int            NOT NULL IDENTITY(1, 1),
        EmployeeNumber  nvarchar(20)   NOT NULL,
        FirstNameEn     nvarchar(100)  NOT NULL,
        LastNameEn      nvarchar(100)  NOT NULL,
        FirstNameAr     nvarchar(100)  NOT NULL,
        LastNameAr      nvarchar(100)  NOT NULL,
        DepartmentId    int            NOT NULL,
        IsActive        bit            NOT NULL CONSTRAINT DF_Employee_IsActive  DEFAULT (1),
        CreatedAt       datetime2(3)   NOT NULL CONSTRAINT DF_Employee_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy       int            NOT NULL,
        ModifiedAt      datetime2(3)   NULL,
        ModifiedBy      int            NULL,
        IsDeleted       bit            NOT NULL CONSTRAINT DF_Employee_IsDeleted DEFAULT (0),
        DeletedAt       datetime2(3)   NULL,
        DeletedBy       int            NULL,
        DeleteReason    nvarchar(500)  NULL,

        CONSTRAINT PK_Employee PRIMARY KEY CLUSTERED (EmployeeId),

        -- Target of Asset's composite FK (AssignedEmployeeId, DepartmentId).
        -- Must exist before script 002 runs, so it lives here.
        CONSTRAINT UQ_Employee_EmployeeId_DepartmentId UNIQUE (EmployeeId, DepartmentId)
    );
END;

/* ----------------------------------------------------------------------------
   Asset
   ---------------------------------------------------------------------------- */

-- Category is not stored: it is derived from AssetType.CategoryId.
-- Assignment columns (AssignedEmployeeId, DepartmentId, LocationId, StatusId)
-- only change through AssetHistory events, never through a plain edit.
IF OBJECT_ID(N'dbo.Asset', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Asset
    (
        AssetId             int            NOT NULL IDENTITY(1, 1),
        AssetCode           nvarchar(50)   NOT NULL,
        AssetName           nvarchar(150)  NOT NULL,
        Description         nvarchar(500)  NULL,
        AssetTypeId         int            NOT NULL,
        ManufacturerId      int            NULL,
        Model               nvarchar(100)  NULL,
        SerialNumber        nvarchar(100)  NULL,
        PurchaseDate        date           NULL,
        PurchaseCost        decimal(18, 2) NULL,   -- Admin-only in the API (R2.6)
        CurrencyId          int            NULL,
        WarrantyExpiryDate  date           NULL,
        StatusId            int            NOT NULL,
        AssignedEmployeeId  int            NULL,
        DepartmentId        int            NULL,
        LocationId          int            NOT NULL,
        RowVersion          rowversion     NOT NULL,   -- optimistic concurrency (R3.5)
        CreatedAt           datetime2(3)   NOT NULL CONSTRAINT DF_Asset_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CreatedBy           int            NOT NULL,
        ModifiedAt          datetime2(3)   NULL,
        ModifiedBy          int            NULL,
        IsDeleted           bit            NOT NULL CONSTRAINT DF_Asset_IsDeleted DEFAULT (0),
        DeletedAt           datetime2(3)   NULL,
        DeletedBy           int            NULL,
        DeleteReason        nvarchar(500)  NULL,

        CONSTRAINT PK_Asset PRIMARY KEY CLUSTERED (AssetId)
    );
END;

/* ----------------------------------------------------------------------------
   AssetHistory (immutable timeline; UPDATE/DELETE blocked by script 005)
   ---------------------------------------------------------------------------- */

-- No Modified/Deleted columns on purpose: rows are written once, never changed.
-- From*/To* columns are plain FKs (script 002), never the composite
-- employee+department pair, so the ON UPDATE CASCADE on Asset can never
-- rewrite history.
IF OBJECT_ID(N'dbo.AssetHistory', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AssetHistory
    (
        AssetHistoryId      bigint         NOT NULL IDENTITY(1, 1),
        AssetId             int            NOT NULL,
        EventTypeId         int            NOT NULL,
        FromStatusId        int            NULL,      -- NULL only for Initial
        ToStatusId          int            NOT NULL,
        FromEmployeeId      int            NULL,
        ToEmployeeId        int            NULL,
        FromDepartmentId    int            NULL,
        ToDepartmentId      int            NULL,
        FromLocationId      int            NULL,      -- NULL only for Initial
        ToLocationId        int            NOT NULL,
        EffectiveDate       date           NOT NULL,  -- business date (Cairo); "not future" checked in the service
        Reason              nvarchar(500)  NULL,
        Note                nvarchar(1000) NULL,
        CorrectsHistoryId   bigint         NULL,      -- filled only for Correction events
        PerformedBy         int            NOT NULL,
        RecordedAt          datetime2(3)   NOT NULL CONSTRAINT DF_AssetHistory_RecordedAt DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_AssetHistory PRIMARY KEY CLUSTERED (AssetHistoryId)
    );
END;

COMMIT TRANSACTION;
GO
