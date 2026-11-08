using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class Manufacturer
{
    public int ManufacturerId { get; set; }

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

    public virtual ICollection<Asset> Assets { get; set; } = new List<Asset>();

    public virtual AppUser CreatedByNavigation { get; set; } = null!;

    public virtual AppUser? DeletedByNavigation { get; set; }

    public virtual AppUser? ModifiedByNavigation { get; set; }
}
