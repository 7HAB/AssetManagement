/* ============================================================================
   005_create_triggers.sql
   Makes AssetHistory immutable at the database level: any UPDATE or DELETE
   is rejected and rolled back.

   This is one of three layers (R3.2):
     1. this trigger,
     2. no update/delete method in the history repository,
     3. no API endpoint that changes history.
   Mistakes are fixed by adding a Correction event, never by editing a row.

   Not covered by a trigger: TRUNCATE TABLE (fails anyway while FKs reference
   the table) and DISABLE TRIGGER (requires ALTER permission, which the
   application and AI logins will not have).

   Re-runnable: CREATE OR ALTER replaces the trigger if it already exists.
   Requires: 001.
   ============================================================================ */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE AssetManagement;
GO

-- CREATE OR ALTER TRIGGER must be the first statement in its batch,
-- which is why it sits between two GO lines.
CREATE OR ALTER TRIGGER dbo.TR_AssetHistory_BlockUpdateDelete
ON dbo.AssetHistory
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- A statement that touched no rows changes nothing; let it pass.
    IF NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;

    -- THROW inside a trigger aborts the statement and rolls back the
    -- whole transaction, so the change never becomes visible.
    THROW 50001, N'AssetHistory is immutable. Record a Correction event instead of updating or deleting a row.', 1;
END;
GO
