/* ============================================================================
   006_create_logins.sql
   Creates two least-privilege SQL logins and their database users:

     asset_app        used by the API for normal work.
                      Can read and write data (db_datareader + db_datawriter).
                      Cannot change the schema, disable triggers, or create logins.

     asset_ai_reader  used ONLY by the AI path (R4.1, defence in depth).
                      Can SELECT the dbo schema, nothing else.
                      Explicitly denied the identity tables (users, tokens).
                      Even if the AI code had a bug, this connection cannot write.

   PASSWORDS
     No password appears in this file (it is committed to git). Each login is
     created with a random password that nobody knows. After running this
     script, set your own password ONCE in a New Query window (do not save it
     in any file):

         ALTER LOGIN asset_app       WITH PASSWORD = N'<your password>';
         ALTER LOGIN asset_ai_reader WITH PASSWORD = N'<your password>';

     Then put the same passwords in the API's user-secrets (connection strings).

   Requires: SQL Server "Mixed Mode" authentication (SQL logins enabled).
             Check: SELECT SERVERPROPERTY('IsIntegratedSecurityOnly');  -> must be 0
   Requires: 000-005. Run as a sysadmin (your Windows login).

   Re-runnable: existing logins, users, roles and memberships are left as they
   are; re-running never resets a password you already set.
   Not wrapped in a transaction: server-level login commands are kept outside
   one on purpose; every step checks before it acts.
   ============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE master;
GO

/* ---- Server logins ----------------------------------------------------------- */

-- The password is built at run time: a random GUID plus characters that satisfy
-- the Windows password policy (upper, lower, digit, symbol). It is never shown.
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'asset_app')
BEGIN
    DECLARE @appPassword nvarchar(128) = CONVERT(nvarchar(36), NEWID()) + N'Aa1!';
    DECLARE @appSql nvarchar(max) =
        N'CREATE LOGIN asset_app WITH PASSWORD = N''' + @appPassword + N''', '
      + N'DEFAULT_DATABASE = AssetManagement, CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;';
    EXEC sys.sp_executesql @appSql;
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'asset_ai_reader')
BEGIN
    DECLARE @aiPassword nvarchar(128) = CONVERT(nvarchar(36), NEWID()) + N'Aa1!';
    DECLARE @aiSql nvarchar(max) =
        N'CREATE LOGIN asset_ai_reader WITH PASSWORD = N''' + @aiPassword + N''', '
      + N'DEFAULT_DATABASE = AssetManagement, CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;';
    EXEC sys.sp_executesql @aiSql;
END;
GO

USE AssetManagement;
GO

/* ---- Database users (a login gets into the server; a user gets into this DB) -- */

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'asset_app')
    CREATE USER asset_app FOR LOGIN asset_app WITH DEFAULT_SCHEMA = dbo;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'asset_ai_reader')
    CREATE USER asset_ai_reader FOR LOGIN asset_ai_reader WITH DEFAULT_SCHEMA = dbo;
GO

/* ---- asset_app: read + write data, nothing more ------------------------------- */

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
    WHERE r.name = N'db_datareader' AND m.name = N'asset_app')
    ALTER ROLE db_datareader ADD MEMBER asset_app;

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
    WHERE r.name = N'db_datawriter' AND m.name = N'asset_app')
    ALTER ROLE db_datawriter ADD MEMBER asset_app;
GO

/* ---- asset_ai_reader: SELECT only, through a dedicated role -------------------- */

-- A custom role (instead of db_datareader) so the DENY rules below are explicit
-- and visible in one place.
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'ai_reader' AND type = 'R')
    CREATE ROLE ai_reader;
GO

GRANT SELECT ON SCHEMA::dbo TO ai_reader;

-- The AI never needs users or tokens. DENY always wins over GRANT.
DENY SELECT ON dbo.AppUser            TO ai_reader;
DENY SELECT ON dbo.RefreshToken       TO ai_reader;
DENY SELECT ON dbo.PasswordResetToken TO ai_reader;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
    WHERE r.name = N'ai_reader' AND m.name = N'asset_ai_reader')
    ALTER ROLE ai_reader ADD MEMBER asset_ai_reader;
GO
