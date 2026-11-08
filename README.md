\# Asset Management System — Backend



Daily progress and decisions: see \[DEVLOG.md].

Frontend repo: https://github.com/7HAB/assetManagementFE



\## 1. Prerequisites \& running

\## 2. Database

\## 3. Architecture

\## 4. Authentication \& authorization

\## 5. Caching

\## 6. AI feature

\## 7. Assumptions, limitations, next steps



##  scaffold 
Scaffold-DbContext "Server=(localdb)\MSSQLLocalDB;Database=AssetManagement;Trusted_Connection=True;TrustServerCertificate=True" Microsoft.EntityFrameworkCore.SqlServer -Project AssetManagement.Infrastructure -StartupProject AssetManagement.Api -Context AssetManagementDbContext -ContextDir Persistence\Generated -ContextNamespace AssetManagement.Infrastructure.Persistence -OutputDir ..\AssetManagement.Domain\Entities\Generated -Namespace AssetManagement.Domain.Entities -NoOnConfiguring -Force