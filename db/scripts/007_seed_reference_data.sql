/* ============================================================================
   007_seed_reference_data.sql
   Seeds the data the application cannot run without:
     - Role             (fixed IDs, mirrored by a C# enum)
     - AssetStatus      (fixed IDs, mirrored by a C# enum, used by CHECKs in 004)
     - AssetEventType   (fixed IDs, mirrored by a C# enum, used by CHECKs in 004)
     - System user      (AppUserId 1; cannot log in; "performed by" for automatic actions)

   Insert-if-missing by ID: an existing row is never overwritten, so names an
   Admin edited later survive a re-run.

   Demo Admin / User accounts are NOT here: their password hashes must come from
   the API's own hasher, so they are added by script 009 with the login work.

   Event type templates: the UI fills the {placeholders} with display names.
     {FromStatus} {ToStatus} {FromLocation} {ToLocation}
     {FromEmployee} {ToEmployee} {FromDepartment} {ToDepartment}
     {From} {To}   = a combined "employee / department / location" text built by the API

   Re-runnable. One transaction. Requires: 000-005.
   ============================================================================ */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
SET NOCOUNT ON;
GO

USE AssetManagement;
GO

BEGIN TRANSACTION;

/* ---- Role -------------------------------------------------------------------------- */

INSERT INTO dbo.Role (RoleId, NameEn, NameAr)
SELECT v.RoleId, v.NameEn, v.NameAr
FROM (VALUES
        (1, N'Admin', N'مسؤول'),
        (2, N'User',  N'مستخدم')
     ) AS v (RoleId, NameEn, NameAr)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Role r WHERE r.RoleId = v.RoleId);

/* ---- AssetStatus ------------------------------------------------------------------- */

INSERT INTO dbo.AssetStatus (AssetStatusId, NameEn, NameAr)
SELECT v.AssetStatusId, v.NameEn, v.NameAr
FROM (VALUES
        (1, N'Available',         N'متاح'),
        (2, N'Assigned',          N'مُسند'),
        (3, N'Under Maintenance', N'تحت الصيانة'),
        (4, N'Retired',           N'خارج الخدمة')
     ) AS v (AssetStatusId, NameEn, NameAr)
WHERE NOT EXISTS (SELECT 1 FROM dbo.AssetStatus s WHERE s.AssetStatusId = v.AssetStatusId);

/* ---- AssetEventType ---------------------------------------------------------------- */

INSERT INTO dbo.AssetEventType (AssetEventTypeId, NameEn, NameAr, TemplateEn, TemplateAr)
SELECT v.AssetEventTypeId, v.NameEn, v.NameAr, v.TemplateEn, v.TemplateAr
FROM (VALUES
        (1, N'Initial', N'تسجيل أولي',
            N'Registered at {ToLocation} with status {ToStatus}.',
            N'تم تسجيل الأصل في {ToLocation} بحالة {ToStatus}.'),
        (2, N'Transfer', N'نقل',
            N'Transferred from {From} to {To}.',
            N'تم النقل من {From} إلى {To}.'),
        (3, N'Status Change', N'تغيير الحالة',
            N'Status changed from {FromStatus} to {ToStatus}.',
            N'تم تغيير الحالة من {FromStatus} إلى {ToStatus}.'),
        (4, N'Correction', N'تصحيح',
            N'Corrected an earlier event; restored {To}.',
            N'تصحيح لحدث سابق؛ تمت الاستعادة إلى {To}.'),
        (5, N'Holder Department Change', N'تغيير قسم الحائز',
            N'Holder {ToEmployee} moved from {FromDepartment} to {ToDepartment}.',
            N'انتقل الحائز {ToEmployee} من {FromDepartment} إلى {ToDepartment}.')
     ) AS v (AssetEventTypeId, NameEn, NameAr, TemplateEn, TemplateAr)
WHERE NOT EXISTS (SELECT 1 FROM dbo.AssetEventType e WHERE e.AssetEventTypeId = v.AssetEventTypeId);

/* ---- System user (AppUserId 1) ----------------------------------------------------- */

-- AppUserId is an IDENTITY column. IDENTITY_INSERT lets this one insert choose
-- the ID itself; afterwards SQL Server continues numbering from 2.
-- CreatedBy = 1 points at the row itself (allowed: the FK is checked after the insert).
-- It can never log in: no password (see CK_AppUser_PasswordHash) and inactive.
IF NOT EXISTS (SELECT 1 FROM dbo.AppUser WHERE AppUserId = 1)
BEGIN
    SET IDENTITY_INSERT dbo.AppUser ON;

    INSERT INTO dbo.AppUser (AppUserId, Username, Email, PasswordHash, RoleId, EmployeeId, IsActive, CreatedBy)
    VALUES (1, N'system', N'system@asset-management.local', NULL, 1, NULL, 0, 1);

    SET IDENTITY_INSERT dbo.AppUser OFF;
END;

COMMIT TRANSACTION;
GO
