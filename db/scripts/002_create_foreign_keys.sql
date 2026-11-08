/* ============================================================================
   002_create_foreign_keys.sql
   Adds every foreign key.

   Delete behaviour: ON DELETE NO ACTION everywhere, no cascading deletes.
   Rows are soft-deleted, and the rule "nothing referenced can be deleted"
   is enforced by the services. These FKs are the last line of defence that
   blocks a hard DELETE of a referenced row.

   Update behaviour: NO ACTION everywhere except FK_Asset_AssignedEmployee_Department
   (ON UPDATE CASCADE, explained below).

   Naming: FK_<Table>_<Column>.

   Re-runnable: each FK is added only if it does not exist yet.
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

IF OBJECT_ID(N'dbo.FK_AssetStatus_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.AssetStatus ADD CONSTRAINT FK_AssetStatus_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetEventType_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.AssetEventType ADD CONSTRAINT FK_AssetEventType_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- AppUser ----------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.FK_AppUser_RoleId', N'F') IS NULL
    ALTER TABLE dbo.AppUser ADD CONSTRAINT FK_AppUser_RoleId
        FOREIGN KEY (RoleId) REFERENCES dbo.Role (RoleId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AppUser_EmployeeId', N'F') IS NULL
    ALTER TABLE dbo.AppUser ADD CONSTRAINT FK_AppUser_EmployeeId
        FOREIGN KEY (EmployeeId) REFERENCES dbo.Employee (EmployeeId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AppUser_CreatedBy', N'F') IS NULL
    ALTER TABLE dbo.AppUser ADD CONSTRAINT FK_AppUser_CreatedBy
        FOREIGN KEY (CreatedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AppUser_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.AppUser ADD CONSTRAINT FK_AppUser_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- RefreshToken ------------------------------------------------------------ */

IF OBJECT_ID(N'dbo.FK_RefreshToken_UserId', N'F') IS NULL
    ALTER TABLE dbo.RefreshToken ADD CONSTRAINT FK_RefreshToken_UserId
        FOREIGN KEY (UserId) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_RefreshToken_ReplacedByTokenId', N'F') IS NULL
    ALTER TABLE dbo.RefreshToken ADD CONSTRAINT FK_RefreshToken_ReplacedByTokenId
        FOREIGN KEY (ReplacedByTokenId) REFERENCES dbo.RefreshToken (RefreshTokenId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- PasswordResetToken ------------------------------------------------------ */

IF OBJECT_ID(N'dbo.FK_PasswordResetToken_UserId', N'F') IS NULL
    ALTER TABLE dbo.PasswordResetToken ADD CONSTRAINT FK_PasswordResetToken_UserId
        FOREIGN KEY (UserId) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- Category ---------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.FK_Category_CreatedBy', N'F') IS NULL
    ALTER TABLE dbo.Category ADD CONSTRAINT FK_Category_CreatedBy
        FOREIGN KEY (CreatedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Category_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.Category ADD CONSTRAINT FK_Category_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Category_DeletedBy', N'F') IS NULL
    ALTER TABLE dbo.Category ADD CONSTRAINT FK_Category_DeletedBy
        FOREIGN KEY (DeletedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- Manufacturer ------------------------------------------------------------ */

IF OBJECT_ID(N'dbo.FK_Manufacturer_CreatedBy', N'F') IS NULL
    ALTER TABLE dbo.Manufacturer ADD CONSTRAINT FK_Manufacturer_CreatedBy
        FOREIGN KEY (CreatedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Manufacturer_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.Manufacturer ADD CONSTRAINT FK_Manufacturer_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Manufacturer_DeletedBy', N'F') IS NULL
    ALTER TABLE dbo.Manufacturer ADD CONSTRAINT FK_Manufacturer_DeletedBy
        FOREIGN KEY (DeletedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- Currency ---------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.FK_Currency_CreatedBy', N'F') IS NULL
    ALTER TABLE dbo.Currency ADD CONSTRAINT FK_Currency_CreatedBy
        FOREIGN KEY (CreatedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Currency_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.Currency ADD CONSTRAINT FK_Currency_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Currency_DeletedBy', N'F') IS NULL
    ALTER TABLE dbo.Currency ADD CONSTRAINT FK_Currency_DeletedBy
        FOREIGN KEY (DeletedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- Department -------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.FK_Department_CreatedBy', N'F') IS NULL
    ALTER TABLE dbo.Department ADD CONSTRAINT FK_Department_CreatedBy
        FOREIGN KEY (CreatedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Department_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.Department ADD CONSTRAINT FK_Department_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Department_DeletedBy', N'F') IS NULL
    ALTER TABLE dbo.Department ADD CONSTRAINT FK_Department_DeletedBy
        FOREIGN KEY (DeletedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- Location ---------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.FK_Location_CreatedBy', N'F') IS NULL
    ALTER TABLE dbo.Location ADD CONSTRAINT FK_Location_CreatedBy
        FOREIGN KEY (CreatedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Location_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.Location ADD CONSTRAINT FK_Location_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Location_DeletedBy', N'F') IS NULL
    ALTER TABLE dbo.Location ADD CONSTRAINT FK_Location_DeletedBy
        FOREIGN KEY (DeletedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- AssetType --------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.FK_AssetType_CategoryId', N'F') IS NULL
    ALTER TABLE dbo.AssetType ADD CONSTRAINT FK_AssetType_CategoryId
        FOREIGN KEY (CategoryId) REFERENCES dbo.Category (CategoryId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetType_CreatedBy', N'F') IS NULL
    ALTER TABLE dbo.AssetType ADD CONSTRAINT FK_AssetType_CreatedBy
        FOREIGN KEY (CreatedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetType_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.AssetType ADD CONSTRAINT FK_AssetType_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetType_DeletedBy', N'F') IS NULL
    ALTER TABLE dbo.AssetType ADD CONSTRAINT FK_AssetType_DeletedBy
        FOREIGN KEY (DeletedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- Employee ---------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.FK_Employee_DepartmentId', N'F') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT FK_Employee_DepartmentId
        FOREIGN KEY (DepartmentId) REFERENCES dbo.Department (DepartmentId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Employee_CreatedBy', N'F') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT FK_Employee_CreatedBy
        FOREIGN KEY (CreatedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Employee_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT FK_Employee_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Employee_DeletedBy', N'F') IS NULL
    ALTER TABLE dbo.Employee ADD CONSTRAINT FK_Employee_DeletedBy
        FOREIGN KEY (DeletedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- Asset ------------------------------------------------------------------- */

IF OBJECT_ID(N'dbo.FK_Asset_AssetTypeId', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_AssetTypeId
        FOREIGN KEY (AssetTypeId) REFERENCES dbo.AssetType (AssetTypeId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Asset_ManufacturerId', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_ManufacturerId
        FOREIGN KEY (ManufacturerId) REFERENCES dbo.Manufacturer (ManufacturerId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Asset_CurrencyId', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_CurrencyId
        FOREIGN KEY (CurrencyId) REFERENCES dbo.Currency (CurrencyId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Asset_StatusId', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_StatusId
        FOREIGN KEY (StatusId) REFERENCES dbo.AssetStatus (AssetStatusId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Asset_DepartmentId', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_DepartmentId
        FOREIGN KEY (DepartmentId) REFERENCES dbo.Department (DepartmentId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Asset_LocationId', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_LocationId
        FOREIGN KEY (LocationId) REFERENCES dbo.Location (LocationId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

-- The one deliberate cascade. When an employee moves department, SQL Server
-- moves the department of every asset they hold in the same statement, so an
-- asset can never point at an employee in a different department.
-- Only enforced when both columns are filled; the status grid (script 004)
-- guarantees DepartmentId is filled whenever AssignedEmployeeId is.
-- There is deliberately no separate single-column FK on AssignedEmployeeId:
-- this composite FK already covers it.
IF OBJECT_ID(N'dbo.FK_Asset_AssignedEmployee_Department', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_AssignedEmployee_Department
        FOREIGN KEY (AssignedEmployeeId, DepartmentId)
        REFERENCES dbo.Employee (EmployeeId, DepartmentId)
        ON DELETE NO ACTION ON UPDATE CASCADE;

IF OBJECT_ID(N'dbo.FK_Asset_CreatedBy', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_CreatedBy
        FOREIGN KEY (CreatedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Asset_ModifiedBy', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_ModifiedBy
        FOREIGN KEY (ModifiedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_Asset_DeletedBy', N'F') IS NULL
    ALTER TABLE dbo.Asset ADD CONSTRAINT FK_Asset_DeletedBy
        FOREIGN KEY (DeletedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

/* ---- AssetHistory (plain FKs only, never the composite pair) ----------------- */

IF OBJECT_ID(N'dbo.FK_AssetHistory_AssetId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_AssetId
        FOREIGN KEY (AssetId) REFERENCES dbo.Asset (AssetId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_EventTypeId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_EventTypeId
        FOREIGN KEY (EventTypeId) REFERENCES dbo.AssetEventType (AssetEventTypeId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_FromStatusId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_FromStatusId
        FOREIGN KEY (FromStatusId) REFERENCES dbo.AssetStatus (AssetStatusId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_ToStatusId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_ToStatusId
        FOREIGN KEY (ToStatusId) REFERENCES dbo.AssetStatus (AssetStatusId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_FromEmployeeId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_FromEmployeeId
        FOREIGN KEY (FromEmployeeId) REFERENCES dbo.Employee (EmployeeId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_ToEmployeeId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_ToEmployeeId
        FOREIGN KEY (ToEmployeeId) REFERENCES dbo.Employee (EmployeeId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_FromDepartmentId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_FromDepartmentId
        FOREIGN KEY (FromDepartmentId) REFERENCES dbo.Department (DepartmentId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_ToDepartmentId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_ToDepartmentId
        FOREIGN KEY (ToDepartmentId) REFERENCES dbo.Department (DepartmentId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_FromLocationId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_FromLocationId
        FOREIGN KEY (FromLocationId) REFERENCES dbo.Location (LocationId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_ToLocationId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_ToLocationId
        FOREIGN KEY (ToLocationId) REFERENCES dbo.Location (LocationId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_CorrectsHistoryId', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_CorrectsHistoryId
        FOREIGN KEY (CorrectsHistoryId) REFERENCES dbo.AssetHistory (AssetHistoryId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

IF OBJECT_ID(N'dbo.FK_AssetHistory_PerformedBy', N'F') IS NULL
    ALTER TABLE dbo.AssetHistory ADD CONSTRAINT FK_AssetHistory_PerformedBy
        FOREIGN KEY (PerformedBy) REFERENCES dbo.AppUser (AppUserId)
        ON DELETE NO ACTION ON UPDATE NO ACTION;

COMMIT TRANSACTION;
GO
