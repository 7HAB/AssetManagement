/* ============================================================================
   000_create_database.sql
   Creates the AssetManagement database.

   Re-runnable: does nothing if the database already exists.
   Run while connected to any database; the script switches to master itself.
   ============================================================================ */

USE master;
GO

IF DB_ID(N'AssetManagement') IS NULL
BEGIN
    -- Collation is set explicitly so uniqueness rules (NameEn, AssetCode, ...)
    -- behave the same on every server, regardless of the server's default.
    --   CI  = case-insensitive  ('Laptop' and 'laptop' are the same value)
    --   AS  = accent-sensitive
    --   SC  = full Unicode support (supplementary characters)
    -- Arabic text is stored correctly because all text columns are nvarchar.
    CREATE DATABASE AssetManagement
        COLLATE Latin1_General_100_CI_AS_SC;
END
GO
