2026-11-08 (Sun)
DB
Wrote and ran scripts 000–008: database, 15 tables, foreign keys, indexes, check constraints, history trigger, logins, reference data, demo data.
Every script is re-runnable; most run in a single transaction.
Demo data built around the brief's AI questions (R4), including two employees called Ahmed to force disambiguation.
BE
Created the solution with four layers: API, Application, Domain, Infrastructure. References point inward only.
Scaffolded the EF Core model from the database (Package Manager Console). Entities in Domain Entities/Generated, DbContext in Infrastructure Persistence/Generated.
Re-ran the scaffold after adding PasswordResetToken: first real schema change end to end, hand-written code unaffected.
Decisions
No Docker (not permitted on this machine) → local SQL Server 2022; Redis setup postponed until caching (needs admin).
Explicit database collation Latin1_General_100_CI_AS_SC: uniqueness must not depend on the server default. Found in practice: the server default is SQL_Latin1_General_CP1_CI_AS, which broke a join with a temp table (fixed with COLLATE DATABASE_DEFAULT).
Two least-privilege logins (R4.1): asset_app (read/write data) and asset_ai_reader (SELECT only, denied user/token tables). Created with random passwords so no secret is committed; real passwords set per machine and kept in user-secrets.
Code-owned lookups with fixed IDs (statuses, event types, roles): C# enums and check constraints depend on the exact numbers.
CHECK constraints accept NULL results, so required text on nullable columns is written x IS NOT NULL AND LEN(x) > 0.
Forgot password added (beyond the brief): PasswordResetToken table (hashed, single use, short expiry).
Scaffold from Visual Studio (Scaffold-DbContext) instead of the dotnet ef CLI.
Token storage (leaning, not final): access token in memory + refresh token in an httpOnly cookie as the default; localStorage and BFF modes possible later behind the same interfaces. Decide before the login work.
Problems hit
Scaffold: dotnet-ef not installed → switched to Package Manager Console.
Scaffold: provider not found → Microsoft.EntityFrameworkCore.SqlServer was missing from Infrastructure.
NuGet warning NU1902: vulnerable indirect package System.Security.Cryptography.Pkcs → pinned to a fixed version.
006 failed on a missing table → old copies of 001–004 had been run; re-ran the new ones.
Next
Build hygiene (global.json, Directory.Build.props, central package versions, .editorconfig).
Typed options, DbContext partial (soft-delete filters, enums), audit stamping, repositories + unit of work, exception handling, logging.