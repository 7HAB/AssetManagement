using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class AssetStatus
{
    public int AssetStatusId { get; set; }

    public string NameEn { get; set; } = null!;

    public string NameAr { get; set; } = null!;

    public DateTime? ModifiedAt { get; set; }

    public int? ModifiedBy { get; set; }

    public virtual ICollection<AssetHistory> AssetHistoryFromStatuses { get; set; } = new List<AssetHistory>();

    public virtual ICollection<AssetHistory> AssetHistoryToStatuses { get; set; } = new List<AssetHistory>();

    public virtual ICollection<Asset> Assets { get; set; } = new List<Asset>();

    public virtual AppUser? ModifiedByNavigation { get; set; }
}
