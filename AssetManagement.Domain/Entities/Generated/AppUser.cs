using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class AppUser
{
    public int AppUserId { get; set; }

    public string Username { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? PasswordHash { get; set; }

    public int RoleId { get; set; }

    public int? EmployeeId { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public int CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public int? ModifiedBy { get; set; }

    public virtual ICollection<Asset> AssetCreatedByNavigations { get; set; } = new List<Asset>();

    public virtual ICollection<Asset> AssetDeletedByNavigations { get; set; } = new List<Asset>();

    public virtual ICollection<AssetEventType> AssetEventTypes { get; set; } = new List<AssetEventType>();

    public virtual ICollection<AssetHistory> AssetHistories { get; set; } = new List<AssetHistory>();

    public virtual ICollection<Asset> AssetModifiedByNavigations { get; set; } = new List<Asset>();

    public virtual ICollection<AssetStatus> AssetStatuses { get; set; } = new List<AssetStatus>();

    public virtual ICollection<AssetType> AssetTypeCreatedByNavigations { get; set; } = new List<AssetType>();

    public virtual ICollection<AssetType> AssetTypeDeletedByNavigations { get; set; } = new List<AssetType>();

    public virtual ICollection<AssetType> AssetTypeModifiedByNavigations { get; set; } = new List<AssetType>();

    public virtual ICollection<Category> CategoryCreatedByNavigations { get; set; } = new List<Category>();

    public virtual ICollection<Category> CategoryDeletedByNavigations { get; set; } = new List<Category>();

    public virtual ICollection<Category> CategoryModifiedByNavigations { get; set; } = new List<Category>();

    public virtual AppUser CreatedByNavigation { get; set; } = null!;

    public virtual ICollection<Currency> CurrencyCreatedByNavigations { get; set; } = new List<Currency>();

    public virtual ICollection<Currency> CurrencyDeletedByNavigations { get; set; } = new List<Currency>();

    public virtual ICollection<Currency> CurrencyModifiedByNavigations { get; set; } = new List<Currency>();

    public virtual ICollection<Department> DepartmentCreatedByNavigations { get; set; } = new List<Department>();

    public virtual ICollection<Department> DepartmentDeletedByNavigations { get; set; } = new List<Department>();

    public virtual ICollection<Department> DepartmentModifiedByNavigations { get; set; } = new List<Department>();

    public virtual Employee? Employee { get; set; }

    public virtual ICollection<Employee> EmployeeCreatedByNavigations { get; set; } = new List<Employee>();

    public virtual ICollection<Employee> EmployeeDeletedByNavigations { get; set; } = new List<Employee>();

    public virtual ICollection<Employee> EmployeeModifiedByNavigations { get; set; } = new List<Employee>();

    public virtual ICollection<AppUser> InverseCreatedByNavigation { get; set; } = new List<AppUser>();

    public virtual ICollection<AppUser> InverseModifiedByNavigation { get; set; } = new List<AppUser>();

    public virtual ICollection<Location> LocationCreatedByNavigations { get; set; } = new List<Location>();

    public virtual ICollection<Location> LocationDeletedByNavigations { get; set; } = new List<Location>();

    public virtual ICollection<Location> LocationModifiedByNavigations { get; set; } = new List<Location>();

    public virtual ICollection<Manufacturer> ManufacturerCreatedByNavigations { get; set; } = new List<Manufacturer>();

    public virtual ICollection<Manufacturer> ManufacturerDeletedByNavigations { get; set; } = new List<Manufacturer>();

    public virtual ICollection<Manufacturer> ManufacturerModifiedByNavigations { get; set; } = new List<Manufacturer>();

    public virtual AppUser? ModifiedByNavigation { get; set; }

    public virtual ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();

    public virtual Role Role { get; set; } = null!;
}
