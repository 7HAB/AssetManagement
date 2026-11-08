/* ============================================================================
   004_create_check_constraints.sql
   Adds check constraints: rules about a single row that the database can
   enforce on its own, so bad data is rejected even if the API has a bug.

   Rules that need other rows (e.g. "effective date not before the previous
   event", "only the latest event can be corrected", "cannot deactivate a
   department that still has assets") are enforced in the services instead.

   Notes
     - LEN(x) > 0 rejects empty and all-space strings (LEN ignores trailing spaces).
     - A CHECK only rejects a row when its condition is FALSE. If it is UNKNOWN
       (because of a NULL) the row is ACCEPTED. So "required text" on a nullable
       column is written as  x IS NOT NULL AND LEN(x) > 0  - never LEN(x) > 0
       alone, which would let NULL through.
     - Rules that use status / event-type IDs rely on the fixed IDs seeded in 007.
     - Naming: CK_<Table>_<Rule>.

   Re-runnable: each constraint is added only if it does not exist yet.
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

/* ---- Code-owned lookups ------------------------------------------------------ */

IF OBJECT_ID(N'dbo.CK_AssetStatus_NameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AssetStatus ADD CONSTRAINT CK_AssetStatus_NameEn_NotBlank
        CHECK (LEN(NameEn) > 0);

IF OBJECT_ID(N'dbo.CK_AssetStatus_NameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AssetStatus ADD CONSTRAINT CK_AssetStatus_NameAr_NotBlank
        CHECK (LEN(NameAr) > 0);

IF OBJECT_ID(N'dbo.CK_AssetStatus_Modified', N'C') IS NULL
    ALTER TABLE dbo.AssetStatus ADD CONSTRAINT CK_AssetStatus_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_AssetEventType_NameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AssetEventType ADD CONSTRAINT CK_AssetEventType_NameEn_NotBlank
        CHECK (LEN(NameEn) > 0);

IF OBJECT_ID(N'dbo.CK_AssetEventType_NameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AssetEventType ADD CONSTRAINT CK_AssetEventType_NameAr_NotBlank
        CHECK (LEN(NameAr) > 0);

IF OBJECT_ID(N'dbo.CK_AssetEventType_Modified', N'C') IS NULL
    ALTER TABLE dbo.AssetEventType ADD CONSTRAINT CK_AssetEventType_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_AssetEventType_TemplateEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AssetEventType ADD CONSTRAINT CK_AssetEventType_TemplateEn_NotBlank
        CHECK (LEN(TemplateEn) > 0);

IF OBJECT_ID(N'dbo.CK_AssetEventType_TemplateAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AssetEventType ADD CONSTRAINT CK_AssetEventType_TemplateAr_NotBlank
        CHECK (LEN(TemplateAr) > 0);

IF OBJECT_ID(N'dbo.CK_Role_NameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Role ADD CONSTRAINT CK_Role_NameEn_NotBlank
        CHECK (LEN(NameEn) > 0);

IF OBJECT_ID(N'dbo.CK_Role_NameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Role ADD CONSTRAINT CK_Role_NameAr_NotBlank
        CHECK (LEN(NameAr) > 0);

/* ---- AppUser ----------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.CK_AppUser_Username_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AppUser ADD CONSTRAINT CK_AppUser_Username_NotBlank
        CHECK (LEN(Username) > 0);

IF OBJECT_ID(N'dbo.CK_AppUser_Email_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AppUser ADD CONSTRAINT CK_AppUser_Email_NotBlank
        CHECK (LEN(Email) > 0);

IF OBJECT_ID(N'dbo.CK_AppUser_Modified', N'C') IS NULL
    ALTER TABLE dbo.AppUser ADD CONSTRAINT CK_AppUser_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

-- Only the System user (ID 1) has no password, which means it can never log in.
IF OBJECT_ID(N'dbo.CK_AppUser_PasswordHash', N'C') IS NULL
    ALTER TABLE dbo.AppUser ADD CONSTRAINT CK_AppUser_PasswordHash
        CHECK (PasswordHash IS NOT NULL OR AppUserId = 1);

/* ---- RefreshToken ------------------------------------------------------------ */

IF OBJECT_ID(N'dbo.CK_RefreshToken_ExpiresAfterCreated', N'C') IS NULL
    ALTER TABLE dbo.RefreshToken ADD CONSTRAINT CK_RefreshToken_ExpiresAfterCreated
        CHECK (ExpiresAt > CreatedAt);

-- A token that was rotated (replaced) must also be marked revoked.
IF OBJECT_ID(N'dbo.CK_RefreshToken_ReplacedImpliesRevoked', N'C') IS NULL
    ALTER TABLE dbo.RefreshToken ADD CONSTRAINT CK_RefreshToken_ReplacedImpliesRevoked
        CHECK (ReplacedByTokenId IS NULL OR RevokedAt IS NOT NULL);

/* ---- Category ---------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.CK_Category_NameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Category ADD CONSTRAINT CK_Category_NameEn_NotBlank
        CHECK (LEN(NameEn) > 0);

IF OBJECT_ID(N'dbo.CK_Category_NameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Category ADD CONSTRAINT CK_Category_NameAr_NotBlank
        CHECK (LEN(NameAr) > 0);

IF OBJECT_ID(N'dbo.CK_Category_Modified', N'C') IS NULL
    ALTER TABLE dbo.Category ADD CONSTRAINT CK_Category_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_Category_SoftDelete', N'C') IS NULL
    ALTER TABLE dbo.Category ADD CONSTRAINT CK_Category_SoftDelete
        CHECK (
               (IsDeleted = 0 AND DeletedAt IS NULL     AND DeletedBy IS NULL     AND DeleteReason IS NULL)
            OR (IsDeleted = 1 AND DeletedAt IS NOT NULL AND DeletedBy IS NOT NULL AND DeleteReason IS NOT NULL AND LEN(DeleteReason) > 0)
        );

/* ---- AssetType --------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.CK_AssetType_NameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AssetType ADD CONSTRAINT CK_AssetType_NameEn_NotBlank
        CHECK (LEN(NameEn) > 0);

IF OBJECT_ID(N'dbo.CK_AssetType_NameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.AssetType ADD CONSTRAINT CK_AssetType_NameAr_NotBlank
        CHECK (LEN(NameAr) > 0);

IF OBJECT_ID(N'dbo.CK_AssetType_Modified', N'C') IS NULL
    ALTER TABLE dbo.AssetType ADD CONSTRAINT CK_AssetType_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_AssetType_SoftDelete', N'C') IS NULL
    ALTER TABLE dbo.AssetType ADD CONSTRAINT CK_AssetType_SoftDelete
        CHECK (
               (IsDeleted = 0 AND DeletedAt IS NULL     AND DeletedBy IS NULL     AND DeleteReason IS NULL)
            OR (IsDeleted = 1 AND DeletedAt IS NOT NULL AND DeletedBy IS NOT NULL AND DeleteReason IS NOT NULL AND LEN(DeleteReason) > 0)
        );

/* ---- Manufacturer ------------------------------------------------------------ */

IF OBJECT_ID(N'dbo.CK_Manufacturer_NameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Manufacturer ADD CONSTRAINT CK_Manufacturer_NameEn_NotBlank
        CHECK (LEN(NameEn) > 0);

IF OBJECT_ID(N'dbo.CK_Manufacturer_NameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Manufacturer ADD CONSTRAINT CK_Manufacturer_NameAr_NotBlank
        CHECK (LEN(NameAr) > 0);

IF OBJECT_ID(N'dbo.CK_Manufacturer_Modified', N'C') IS NULL
    ALTER TABLE dbo.Manufacturer ADD CONSTRAINT CK_Manufacturer_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_Manufacturer_SoftDelete', N'C') IS NULL
    ALTER TABLE dbo.Manufacturer ADD CONSTRAINT CK_Manufacturer_SoftDelete
        CHECK (
               (IsDeleted = 0 AND DeletedAt IS NULL     AND DeletedBy IS NULL     AND DeleteReason IS NULL)
            OR (IsDeleted = 1 AND DeletedAt IS NOT NULL AND DeletedBy IS NOT NULL AND DeleteReason IS NOT NULL AND LEN(DeleteReason) > 0)
        );

/* ---- Currency ---------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.CK_Currency_NameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Currency ADD CONSTRAINT CK_Currency_NameEn_NotBlank
        CHECK (LEN(NameEn) > 0);

IF OBJECT_ID(N'dbo.CK_Currency_NameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Currency ADD CONSTRAINT CK_Currency_NameAr_NotBlank
        CHECK (LEN(NameAr) > 0);

IF OBJECT_ID(N'dbo.CK_Currency_Modified', N'C') IS NULL
    ALTER TABLE dbo.Currency ADD CONSTRAINT CK_Currency_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_Currency_SoftDelete', N'C') IS NULL
    ALTER TABLE dbo.Currency ADD CONSTRAINT CK_Currency_SoftDelete
        CHECK (
               (IsDeleted = 0 AND DeletedAt IS NULL     AND DeletedBy IS NULL     AND DeleteReason IS NULL)
            OR (IsDeleted = 1 AND DeletedAt IS NOT NULL AND DeletedBy IS NOT NULL AND DeleteReason IS NOT NULL AND LEN(DeleteReason) > 0)
        );

-- Three uppercase letters (ISO 4217). BIN2 collation makes [A-Z] reject lowercase,
-- which the case-insensitive database collation would otherwise accept.
IF OBJECT_ID(N'dbo.CK_Currency_Code_Format', N'C') IS NULL
    ALTER TABLE dbo.Currency ADD CONSTRAINT CK_Currency_Code_Format
        CHECK (Code COLLATE Latin1_General_100_BIN2 LIKE '[A-Z][A-Z][A-Z]');

/* ---- Department -------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.CK_Department_NameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Department ADD CONSTRAINT CK_Department_NameEn_NotBlank
        CHECK (LEN(NameEn) > 0);

IF OBJECT_ID(N'dbo.CK_Department_NameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Department ADD CONSTRAINT CK_Department_NameAr_NotBlank
        CHECK (LEN(NameAr) > 0);

IF OBJECT_ID(N'dbo.CK_Department_Modified', N'C') IS NULL
    ALTER TABLE dbo.Department ADD CONSTRAINT CK_Department_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_Department_SoftDelete', N'C') IS NULL
    ALTER TABLE dbo.Department ADD CONSTRAINT CK_Department_SoftDelete
        CHECK (
               (IsDeleted = 0 AND DeletedAt IS NULL     AND DeletedBy IS NULL     AND DeleteReason IS NULL)
            OR (IsDeleted = 1 AND DeletedAt IS NOT NULL AND DeletedBy IS NOT NULL AND DeleteReason IS NOT NULL AND LEN(DeleteReason) > 0)
        );

/* ---- Location ---------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.CK_Location_NameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Location ADD CONSTRAINT CK_Location_NameEn_NotBlank
        CHECK (LEN(NameEn) > 0);

IF OBJECT_ID(N'dbo.CK_Location_NameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Location ADD CONSTRAINT CK_Location_NameAr_NotBlank
        CHECK (LEN(NameAr) > 0);

IF OBJECT_ID(N'dbo.CK_Location_Modified', N'C') IS NULL
    ALTER TABLE dbo.Location ADD CONSTRAINT CK_Location_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_Location_SoftDelete', N'C') IS NULL
    ALTER TABLE dbo.Location ADD CONSTRAINT CK_Location_SoftDelete
        CHECK (
               (IsDeleted = 0 AND DeletedAt IS NULL     AND DeletedBy IS NULL     AND DeleteReason IS NULL)
            OR (IsDeleted = 1 AND DeletedAt IS NOT NULL AND DeletedBy IS NOT NULL AND DeleteReason IS NOT NULL AND LEN(DeleteReason) > 0)
        );

/* ---- Employee ---------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.CK_Employee_EmployeeNumber_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT CK_Employee_EmployeeNumber_NotBlank
        CHECK (LEN(EmployeeNumber) > 0);

IF OBJECT_ID(N'dbo.CK_Employee_FirstNameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT CK_Employee_FirstNameEn_NotBlank
        CHECK (LEN(FirstNameEn) > 0);

IF OBJECT_ID(N'dbo.CK_Employee_LastNameEn_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT CK_Employee_LastNameEn_NotBlank
        CHECK (LEN(LastNameEn) > 0);

IF OBJECT_ID(N'dbo.CK_Employee_FirstNameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT CK_Employee_FirstNameAr_NotBlank
        CHECK (LEN(FirstNameAr) > 0);

IF OBJECT_ID(N'dbo.CK_Employee_LastNameAr_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT CK_Employee_LastNameAr_NotBlank
        CHECK (LEN(LastNameAr) > 0);

IF OBJECT_ID(N'dbo.CK_Employee_Modified', N'C') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT CK_Employee_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_Employee_SoftDelete', N'C') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT CK_Employee_SoftDelete
        CHECK (
               (IsDeleted = 0 AND DeletedAt IS NULL     AND DeletedBy IS NULL     AND DeleteReason IS NULL)
            OR (IsDeleted = 1 AND DeletedAt IS NOT NULL AND DeletedBy IS NOT NULL AND DeleteReason IS NOT NULL AND LEN(DeleteReason) > 0)
        );

/* ---- Asset ------------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.CK_Asset_AssetCode_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT CK_Asset_AssetCode_NotBlank
        CHECK (LEN(AssetCode) > 0);

IF OBJECT_ID(N'dbo.CK_Asset_AssetName_NotBlank', N'C') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT CK_Asset_AssetName_NotBlank
        CHECK (LEN(AssetName) > 0);

IF OBJECT_ID(N'dbo.CK_Asset_Modified', N'C') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT CK_Asset_Modified
        CHECK ((ModifiedAt IS NULL AND ModifiedBy IS NULL) OR (ModifiedAt IS NOT NULL AND ModifiedBy IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_Asset_SoftDelete', N'C') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT CK_Asset_SoftDelete
        CHECK (
               (IsDeleted = 0 AND DeletedAt IS NULL     AND DeletedBy IS NULL     AND DeleteReason IS NULL)
            OR (IsDeleted = 1 AND DeletedAt IS NOT NULL AND DeletedBy IS NOT NULL AND DeleteReason IS NOT NULL AND LEN(DeleteReason) > 0)
        );

IF OBJECT_ID(N'dbo.CK_Asset_PurchaseCost_NonNegative', N'C') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT CK_Asset_PurchaseCost_NonNegative
        CHECK (PurchaseCost IS NULL OR PurchaseCost >= 0);

-- Cost and currency come together or not at all (a number without a currency is meaningless).
IF OBJECT_ID(N'dbo.CK_Asset_CostAndCurrency', N'C') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT CK_Asset_CostAndCurrency
        CHECK ((PurchaseCost IS NULL AND CurrencyId IS NULL) OR (PurchaseCost IS NOT NULL AND CurrencyId IS NOT NULL));

IF OBJECT_ID(N'dbo.CK_Asset_WarrantyAfterPurchase', N'C') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT CK_Asset_WarrantyAfterPurchase
        CHECK (WarrantyExpiryDate IS NULL OR PurchaseDate IS NULL OR WarrantyExpiryDate >= PurchaseDate);

-- Status grid (IDs are fixed, see AssetStatus seed in 007):
--   1 Available          no employee, no department
--   2 Assigned           department required, employee optional
--   3 Under Maintenance  department required, employee optional (keeps holder)
--   4 Retired            no employee, no department
-- Because a filled employee always means a filled department, the composite
-- FK in 002 is always enforced when an employee is assigned.
IF OBJECT_ID(N'dbo.CK_Asset_StatusAssignment', N'C') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT CK_Asset_StatusAssignment
        CHECK (
               (StatusId IN (1, 4) AND AssignedEmployeeId IS NULL AND DepartmentId IS NULL)
            OR (StatusId IN (2, 3) AND DepartmentId IS NOT NULL)
        );

/* ---- AssetHistory ------------------------------------------------------------ */

-- Event types (IDs are fixed, see AssetEventType seed in 007):
--   1 Initial  2 Transfer  3 Status Change  4 Correction  5 Holder Department Change

-- Initial starts from nothing. Every later event starts from a known status and
-- location, because an asset always has both.
IF OBJECT_ID(N'dbo.CK_AssetHistory_InitialHasNoFrom', N'C') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT CK_AssetHistory_InitialHasNoFrom
        CHECK (
               (EventTypeId = 1  AND FromStatusId IS NULL AND FromEmployeeId IS NULL
                                 AND FromDepartmentId IS NULL AND FromLocationId IS NULL)
            OR (EventTypeId <> 1 AND FromStatusId IS NOT NULL AND FromLocationId IS NOT NULL)
        );

-- Reason is required for Transfer, Status Change and Correction.
IF OBJECT_ID(N'dbo.CK_AssetHistory_ReasonRequired', N'C') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT CK_AssetHistory_ReasonRequired
        CHECK (EventTypeId NOT IN (2, 3, 4) OR (Reason IS NOT NULL AND LEN(Reason) > 0));

-- CorrectsHistoryId is filled if and only if the event is a Correction.
IF OBJECT_ID(N'dbo.CK_AssetHistory_CorrectionLink', N'C') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT CK_AssetHistory_CorrectionLink
        CHECK (
               (EventTypeId = 4  AND CorrectsHistoryId IS NOT NULL)
            OR (EventTypeId <> 4 AND CorrectsHistoryId IS NULL)
        );

-- A Transfer must change at least one of employee, department, location.
-- Comparisons are null-safe: NULL -> NULL counts as "unchanged".
-- Locations are never NULL on a Transfer (see InitialHasNoFrom / ToLocationId).
IF OBJECT_ID(N'dbo.CK_AssetHistory_TransferChangesSomething', N'C') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT CK_AssetHistory_TransferChangesSomething
        CHECK (
               EventTypeId <> 2
            OR NOT (    (FromEmployeeId   = ToEmployeeId   OR (FromEmployeeId   IS NULL AND ToEmployeeId   IS NULL))
                    AND (FromDepartmentId = ToDepartmentId OR (FromDepartmentId IS NULL AND ToDepartmentId IS NULL))
                    AND  FromLocationId   = ToLocationId)
        );

-- A Status Change must change the status.
IF OBJECT_ID(N'dbo.CK_AssetHistory_StatusChangeChangesStatus', N'C') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT CK_AssetHistory_StatusChangeChangesStatus
        CHECK (EventTypeId <> 3 OR FromStatusId <> ToStatusId);

-- A Holder Department Change must change the department.
IF OBJECT_ID(N'dbo.CK_AssetHistory_HolderDeptChangeChangesDept', N'C') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT CK_AssetHistory_HolderDeptChangeChangesDept
        CHECK (
               EventTypeId <> 5
            OR NOT (FromDepartmentId = ToDepartmentId OR (FromDepartmentId IS NULL AND ToDepartmentId IS NULL))
        );

IF OBJECT_ID(N'dbo.CK_AssetHistory_NotSelfCorrecting', N'C') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT CK_AssetHistory_NotSelfCorrecting
        CHECK (CorrectsHistoryId IS NULL OR CorrectsHistoryId <> AssetHistoryId);

COMMIT TRANSACTION;
GO
