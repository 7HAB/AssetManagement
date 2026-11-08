using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class Location
{
    public int LocationId { get; set; }

    public string NameEn { get; set; } = null!;

    public string NameAr { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public int CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public int? ModifiedBy { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime? DeletedAt { get; set; }

    public int? DeletedBy { get; set; }

    public string? DeleteReason { get; set; }

    public virtual ICollection<AssetHistory> AssetHistoryFromLocations { get; set; } = new List<AssetHistory>();

    public virtual ICollection<AssetHistory> AssetHistoryToLocations { get; set; } = new List<AssetHistory>();

    public virtual ICollection<Asset> Assets { get; set; } = new List<Asset>();

    public virtual AppUser CreatedByNavigation { get; set; } = null!;

    public virtual AppUser? DeletedByNavigation { get; set; }

    public virtual AppUser? ModifiedByNavigation { get; set; }
}
