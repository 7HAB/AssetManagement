using System;
using System.Collections.Generic;
using System.Text;

using AssetManagement.Domain.Entities;

using Microsoft.EntityFrameworkCore;

namespace AssetManagement.Infrastructure.Persistence;

public partial class AssetManagementDbContext
{
    /// <summary>
    /// Name of soft delete query filter used with IgnoreQueryFilters.
    /// </summary>
    public const string SoftDeleteQueryFilter = "SoftDeleteQueryFilter";

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        ApplySoftDeleteQueryFilter(modelBuilder);
    }

    /// <summary>
    /// Hide soft eleted rows from every query by defaul.
    /// Every table with an isDeleted column must be listed here.
    /// </summary>

    private static void ApplySoftDeleteQueryFilter(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Category>().HasQueryFilter(SoftDeleteQueryFilter, e => !e.IsDeleted);
        modelBuilder.Entity<AssetType>().HasQueryFilter(SoftDeleteQueryFilter, e => !e.IsDeleted);
        modelBuilder.Entity<Manufacturer>().HasQueryFilter(SoftDeleteQueryFilter, e => !e.IsDeleted);
        modelBuilder.Entity<Currency>().HasQueryFilter(SoftDeleteQueryFilter, e => !e.IsDeleted);
        modelBuilder.Entity<Department>().HasQueryFilter(SoftDeleteQueryFilter, e => !e.IsDeleted);
        modelBuilder.Entity<Location>().HasQueryFilter(SoftDeleteQueryFilter, e => !e.IsDeleted);
        modelBuilder.Entity<Employee>().HasQueryFilter(SoftDeleteQueryFilter, e => !e.IsDeleted);
        modelBuilder.Entity<Asset>().HasQueryFilter(SoftDeleteQueryFilter, e => !e.IsDeleted);
        modelBuilder.Entity<AssetHistory>().HasQueryFilter(SoftDeleteQueryFilter, h => !h.Asset.IsDeleted);
    }

}
