using System;
using System.Collections.Generic;
using AssetManagement.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace AssetManagement.Infrastructure.Persistence;

public partial class AssetManagementDbContext : DbContext
{
    public AssetManagementDbContext(DbContextOptions<AssetManagementDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AppUser> AppUsers { get; set; }

    public virtual DbSet<Asset> Assets { get; set; }

    public virtual DbSet<AssetEventType> AssetEventTypes { get; set; }

    public virtual DbSet<AssetHistory> AssetHistories { get; set; }

    public virtual DbSet<AssetStatus> AssetStatuses { get; set; }

    public virtual DbSet<AssetType> AssetTypes { get; set; }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<Currency> Currencies { get; set; }

    public virtual DbSet<Department> Departments { get; set; }

    public virtual DbSet<Employee> Employees { get; set; }

    public virtual DbSet<Location> Locations { get; set; }

    public virtual DbSet<Manufacturer> Manufacturers { get; set; }

    public virtual DbSet<RefreshToken> RefreshTokens { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.UseCollation("Latin1_General_100_CI_AS_SC");

        modelBuilder.Entity<AppUser>(entity =>
        {
            entity.ToTable("AppUser");

            entity.HasIndex(e => e.Email, "UX_AppUser_Email").IsUnique();

            entity.HasIndex(e => e.EmployeeId, "UX_AppUser_EmployeeId")
                .IsUnique()
                .HasFilter("([EmployeeId] IS NOT NULL)");

            entity.HasIndex(e => e.Username, "UX_AppUser_Username").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_AppUser_CreatedAt");
            entity.Property(e => e.Email).HasMaxLength(256);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_AppUser_IsActive");
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.PasswordHash).HasMaxLength(500);
            entity.Property(e => e.Username).HasMaxLength(50);

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.InverseCreatedByNavigation)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AppUser_CreatedBy");

            entity.HasOne(d => d.Employee).WithOne(p => p.AppUser)
                .HasForeignKey<AppUser>(d => d.EmployeeId)
                .HasConstraintName("FK_AppUser_EmployeeId");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.InverseModifiedByNavigation)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_AppUser_ModifiedBy");

            entity.HasOne(d => d.Role).WithMany(p => p.AppUsers)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AppUser_RoleId");
        });

        modelBuilder.Entity<Asset>(entity =>
        {
            entity.ToTable("Asset");

            entity.HasIndex(e => e.AssetTypeId, "IX_Asset_AssetTypeId");

            entity.HasIndex(e => new { e.AssignedEmployeeId, e.DepartmentId }, "IX_Asset_AssignedEmployeeId_DepartmentId");

            entity.HasIndex(e => e.DepartmentId, "IX_Asset_DepartmentId");

            entity.HasIndex(e => e.LocationId, "IX_Asset_LocationId");

            entity.HasIndex(e => e.ManufacturerId, "IX_Asset_ManufacturerId");

            entity.HasIndex(e => e.StatusId, "IX_Asset_StatusId");

            entity.HasIndex(e => e.AssetCode, "UX_Asset_AssetCode")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0))");

            entity.HasIndex(e => e.SerialNumber, "UX_Asset_SerialNumber")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0) AND [SerialNumber] IS NOT NULL)");

            entity.Property(e => e.AssetCode).HasMaxLength(50);
            entity.Property(e => e.AssetName).HasMaxLength(150);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Asset_CreatedAt");
            entity.Property(e => e.DeleteReason).HasMaxLength(500);
            entity.Property(e => e.DeletedAt).HasPrecision(3);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.Model).HasMaxLength(100);
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.PurchaseCost).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.RowVersion)
                .IsRowVersion()
                .IsConcurrencyToken();
            entity.Property(e => e.SerialNumber).HasMaxLength(100);

            entity.HasOne(d => d.AssetType).WithMany(p => p.Assets)
                .HasForeignKey(d => d.AssetTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Asset_AssetTypeId");

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.AssetCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Asset_CreatedBy");

            entity.HasOne(d => d.Currency).WithMany(p => p.Assets)
                .HasForeignKey(d => d.CurrencyId)
                .HasConstraintName("FK_Asset_CurrencyId");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.AssetDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_Asset_DeletedBy");

            entity.HasOne(d => d.Department).WithMany(p => p.Assets)
                .HasForeignKey(d => d.DepartmentId)
                .HasConstraintName("FK_Asset_DepartmentId");

            entity.HasOne(d => d.Location).WithMany(p => p.Assets)
                .HasForeignKey(d => d.LocationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Asset_LocationId");

            entity.HasOne(d => d.Manufacturer).WithMany(p => p.Assets)
                .HasForeignKey(d => d.ManufacturerId)
                .HasConstraintName("FK_Asset_ManufacturerId");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.AssetModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_Asset_ModifiedBy");

            entity.HasOne(d => d.Status).WithMany(p => p.Assets)
                .HasForeignKey(d => d.StatusId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Asset_StatusId");

            entity.HasOne(d => d.Employee).WithMany(p => p.Assets)
                .HasPrincipalKey(p => new { p.EmployeeId, p.DepartmentId })
                .HasForeignKey(d => new { d.AssignedEmployeeId, d.DepartmentId })
                .HasConstraintName("FK_Asset_AssignedEmployee_Department");
        });

        modelBuilder.Entity<AssetEventType>(entity =>
        {
            entity.ToTable("AssetEventType");

            entity.HasIndex(e => e.NameEn, "UX_AssetEventType_NameEn").IsUnique();

            entity.Property(e => e.AssetEventTypeId).ValueGeneratedNever();
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.NameAr).HasMaxLength(100);
            entity.Property(e => e.NameEn).HasMaxLength(100);
            entity.Property(e => e.TemplateAr).HasMaxLength(500);
            entity.Property(e => e.TemplateEn).HasMaxLength(500);

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.AssetEventTypes)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_AssetEventType_ModifiedBy");
        });

        modelBuilder.Entity<AssetHistory>(entity =>
        {
            entity.ToTable("AssetHistory", tb => tb.HasTrigger("TR_AssetHistory_BlockUpdateDelete"));

            entity.HasIndex(e => new { e.AssetId, e.EffectiveDate, e.AssetHistoryId }, "IX_AssetHistory_AssetId_EffectiveDate");

            entity.HasIndex(e => e.CorrectsHistoryId, "UX_AssetHistory_CorrectsHistoryId")
                .IsUnique()
                .HasFilter("([CorrectsHistoryId] IS NOT NULL)");

            entity.Property(e => e.Note).HasMaxLength(1000);
            entity.Property(e => e.Reason).HasMaxLength(500);
            entity.Property(e => e.RecordedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_AssetHistory_RecordedAt");

            entity.HasOne(d => d.Asset).WithMany(p => p.AssetHistories)
                .HasForeignKey(d => d.AssetId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AssetHistory_AssetId");

            entity.HasOne(d => d.CorrectsHistory).WithOne(p => p.InverseCorrectsHistory)
                .HasForeignKey<AssetHistory>(d => d.CorrectsHistoryId)
                .HasConstraintName("FK_AssetHistory_CorrectsHistoryId");

            entity.HasOne(d => d.EventType).WithMany(p => p.AssetHistories)
                .HasForeignKey(d => d.EventTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AssetHistory_EventTypeId");

            entity.HasOne(d => d.FromDepartment).WithMany(p => p.AssetHistoryFromDepartments)
                .HasForeignKey(d => d.FromDepartmentId)
                .HasConstraintName("FK_AssetHistory_FromDepartmentId");

            entity.HasOne(d => d.FromEmployee).WithMany(p => p.AssetHistoryFromEmployees)
                .HasForeignKey(d => d.FromEmployeeId)
                .HasConstraintName("FK_AssetHistory_FromEmployeeId");

            entity.HasOne(d => d.FromLocation).WithMany(p => p.AssetHistoryFromLocations)
                .HasForeignKey(d => d.FromLocationId)
                .HasConstraintName("FK_AssetHistory_FromLocationId");

            entity.HasOne(d => d.FromStatus).WithMany(p => p.AssetHistoryFromStatuses)
                .HasForeignKey(d => d.FromStatusId)
                .HasConstraintName("FK_AssetHistory_FromStatusId");

            entity.HasOne(d => d.PerformedByNavigation).WithMany(p => p.AssetHistories)
                .HasForeignKey(d => d.PerformedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AssetHistory_PerformedBy");

            entity.HasOne(d => d.ToDepartment).WithMany(p => p.AssetHistoryToDepartments)
                .HasForeignKey(d => d.ToDepartmentId)
                .HasConstraintName("FK_AssetHistory_ToDepartmentId");

            entity.HasOne(d => d.ToEmployee).WithMany(p => p.AssetHistoryToEmployees)
                .HasForeignKey(d => d.ToEmployeeId)
                .HasConstraintName("FK_AssetHistory_ToEmployeeId");

            entity.HasOne(d => d.ToLocation).WithMany(p => p.AssetHistoryToLocations)
                .HasForeignKey(d => d.ToLocationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AssetHistory_ToLocationId");

            entity.HasOne(d => d.ToStatus).WithMany(p => p.AssetHistoryToStatuses)
                .HasForeignKey(d => d.ToStatusId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AssetHistory_ToStatusId");
        });

        modelBuilder.Entity<AssetStatus>(entity =>
        {
            entity.ToTable("AssetStatus");

            entity.HasIndex(e => e.NameEn, "UX_AssetStatus_NameEn").IsUnique();

            entity.Property(e => e.AssetStatusId).ValueGeneratedNever();
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.NameAr).HasMaxLength(100);
            entity.Property(e => e.NameEn).HasMaxLength(100);

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.AssetStatuses)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_AssetStatus_ModifiedBy");
        });

        modelBuilder.Entity<AssetType>(entity =>
        {
            entity.ToTable("AssetType");

            entity.HasIndex(e => e.CategoryId, "IX_AssetType_CategoryId");

            entity.HasIndex(e => e.NameEn, "UX_AssetType_NameEn")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0))");

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_AssetType_CreatedAt");
            entity.Property(e => e.DeleteReason).HasMaxLength(500);
            entity.Property(e => e.DeletedAt).HasPrecision(3);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_AssetType_IsActive");
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.NameAr).HasMaxLength(100);
            entity.Property(e => e.NameEn).HasMaxLength(100);

            entity.HasOne(d => d.Category).WithMany(p => p.AssetTypes)
                .HasForeignKey(d => d.CategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AssetType_CategoryId");

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.AssetTypeCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AssetType_CreatedBy");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.AssetTypeDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_AssetType_DeletedBy");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.AssetTypeModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_AssetType_ModifiedBy");
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.ToTable("Category");

            entity.HasIndex(e => e.NameEn, "UX_Category_NameEn")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0))");

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Category_CreatedAt");
            entity.Property(e => e.DeleteReason).HasMaxLength(500);
            entity.Property(e => e.DeletedAt).HasPrecision(3);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Category_IsActive");
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.NameAr).HasMaxLength(100);
            entity.Property(e => e.NameEn).HasMaxLength(100);

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.CategoryCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Category_CreatedBy");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.CategoryDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_Category_DeletedBy");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.CategoryModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_Category_ModifiedBy");
        });

        modelBuilder.Entity<Currency>(entity =>
        {
            entity.ToTable("Currency");

            entity.HasIndex(e => e.Code, "UX_Currency_Code")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0))");

            entity.HasIndex(e => e.NameEn, "UX_Currency_NameEn")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0))");

            entity.Property(e => e.Code)
                .HasMaxLength(3)
                .IsUnicode(false)
                .IsFixedLength();
            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Currency_CreatedAt");
            entity.Property(e => e.DeleteReason).HasMaxLength(500);
            entity.Property(e => e.DeletedAt).HasPrecision(3);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Currency_IsActive");
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.NameAr).HasMaxLength(100);
            entity.Property(e => e.NameEn).HasMaxLength(100);

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.CurrencyCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Currency_CreatedBy");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.CurrencyDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_Currency_DeletedBy");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.CurrencyModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_Currency_ModifiedBy");
        });

        modelBuilder.Entity<Department>(entity =>
        {
            entity.ToTable("Department");

            entity.HasIndex(e => e.NameEn, "UX_Department_NameEn")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0))");

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Department_CreatedAt");
            entity.Property(e => e.DeleteReason).HasMaxLength(500);
            entity.Property(e => e.DeletedAt).HasPrecision(3);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Department_IsActive");
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.NameAr).HasMaxLength(100);
            entity.Property(e => e.NameEn).HasMaxLength(100);

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.DepartmentCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Department_CreatedBy");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.DepartmentDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_Department_DeletedBy");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.DepartmentModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_Department_ModifiedBy");
        });

        modelBuilder.Entity<Employee>(entity =>
        {
            entity.ToTable("Employee");

            entity.HasIndex(e => e.DepartmentId, "IX_Employee_DepartmentId");

            entity.HasIndex(e => new { e.EmployeeId, e.DepartmentId }, "UQ_Employee_EmployeeId_DepartmentId").IsUnique();

            entity.HasIndex(e => e.EmployeeNumber, "UX_Employee_EmployeeNumber")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0))");

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Employee_CreatedAt");
            entity.Property(e => e.DeleteReason).HasMaxLength(500);
            entity.Property(e => e.DeletedAt).HasPrecision(3);
            entity.Property(e => e.EmployeeNumber).HasMaxLength(20);
            entity.Property(e => e.FirstNameAr).HasMaxLength(100);
            entity.Property(e => e.FirstNameEn).HasMaxLength(100);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Employee_IsActive");
            entity.Property(e => e.LastNameAr).HasMaxLength(100);
            entity.Property(e => e.LastNameEn).HasMaxLength(100);
            entity.Property(e => e.ModifiedAt).HasPrecision(3);

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.EmployeeCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Employee_CreatedBy");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.EmployeeDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_Employee_DeletedBy");

            entity.HasOne(d => d.Department).WithMany(p => p.Employees)
                .HasForeignKey(d => d.DepartmentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Employee_DepartmentId");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.EmployeeModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_Employee_ModifiedBy");
        });

        modelBuilder.Entity<Location>(entity =>
        {
            entity.ToTable("Location");

            entity.HasIndex(e => e.NameEn, "UX_Location_NameEn")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0))");

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Location_CreatedAt");
            entity.Property(e => e.DeleteReason).HasMaxLength(500);
            entity.Property(e => e.DeletedAt).HasPrecision(3);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Location_IsActive");
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.NameAr).HasMaxLength(100);
            entity.Property(e => e.NameEn).HasMaxLength(100);

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.LocationCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Location_CreatedBy");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.LocationDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_Location_DeletedBy");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.LocationModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_Location_ModifiedBy");
        });

        modelBuilder.Entity<Manufacturer>(entity =>
        {
            entity.ToTable("Manufacturer");

            entity.HasIndex(e => e.NameEn, "UX_Manufacturer_NameEn")
                .IsUnique()
                .HasFilter("([IsDeleted]=(0))");

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_Manufacturer_CreatedAt");
            entity.Property(e => e.DeleteReason).HasMaxLength(500);
            entity.Property(e => e.DeletedAt).HasPrecision(3);
            entity.Property(e => e.IsActive).HasDefaultValue(true, "DF_Manufacturer_IsActive");
            entity.Property(e => e.ModifiedAt).HasPrecision(3);
            entity.Property(e => e.NameAr).HasMaxLength(100);
            entity.Property(e => e.NameEn).HasMaxLength(100);

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.ManufacturerCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Manufacturer_CreatedBy");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.ManufacturerDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_Manufacturer_DeletedBy");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.ManufacturerModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_Manufacturer_ModifiedBy");
        });

        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.ToTable("RefreshToken");

            entity.HasIndex(e => e.UserId, "IX_RefreshToken_UserId");

            entity.HasIndex(e => e.TokenHash, "UX_RefreshToken_TokenHash").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasPrecision(3)
                .HasDefaultValueSql("(sysutcdatetime())", "DF_RefreshToken_CreatedAt");
            entity.Property(e => e.ExpiresAt).HasPrecision(3);
            entity.Property(e => e.RevokedAt).HasPrecision(3);
            entity.Property(e => e.TokenHash)
                .HasMaxLength(32)
                .IsFixedLength();

            entity.HasOne(d => d.ReplacedByToken).WithMany(p => p.InverseReplacedByToken)
                .HasForeignKey(d => d.ReplacedByTokenId)
                .HasConstraintName("FK_RefreshToken_ReplacedByTokenId");

            entity.HasOne(d => d.User).WithMany(p => p.RefreshTokens)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RefreshToken_UserId");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.ToTable("Role");

            entity.HasIndex(e => e.NameEn, "UX_Role_NameEn").IsUnique();

            entity.Property(e => e.RoleId).ValueGeneratedNever();
            entity.Property(e => e.NameAr).HasMaxLength(50);
            entity.Property(e => e.NameEn).HasMaxLength(50);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
