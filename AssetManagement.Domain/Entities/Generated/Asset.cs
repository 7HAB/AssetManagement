using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class Asset
{
    public int AssetId { get; set; }

    public string AssetCode { get; set; } = null!;

    public string AssetName { get; set; } = null!;

    public string? Description { get; set; }

    public int AssetTypeId { get; set; }

    public int? ManufacturerId { get; set; }

    public string? Model { get; set; }

    public string? SerialNumber { get; set; }

    public DateOnly? PurchaseDate { get; set; }

    public decimal? PurchaseCost { get; set; }

    public int? CurrencyId { get; set; }

    public DateOnly? WarrantyExpiryDate { get; set; }

    public int StatusId { get; set; }

    public int? AssignedEmployeeId { get; set; }

    public int? DepartmentId { get; set; }

    public int LocationId { get; set; }

    public byte[] RowVersion { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public int CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public int? ModifiedBy { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? DeletedAt { get; set; }

    public int? DeletedBy { get; set; }

    public string? DeleteReason { get; set; }

    public virtual ICollection<AssetHistory> AssetHistories { get; set; } = new List<AssetHistory>();

    public virtual AssetType AssetType { get; set; } = null!;

    public virtual AppUser CreatedByNavigation { get; set; } = null!;

    public virtual Currency? Currency { get; set; }

    public virtual AppUser? DeletedByNavigation { get; set; }

    public virtual Department? Department { get; set; }

    public virtual Employee? Employee { get; set; }

    public virtual Location Location { get; set; } = null!;

    public virtual Manufacturer? Manufacturer { get; set; }

    public virtual AppUser? ModifiedByNavigation { get; set; }

    public virtual AssetStatus Status { get; set; } = null!;
}
