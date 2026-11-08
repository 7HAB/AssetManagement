using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class AssetEventType
{
    public int AssetEventTypeId { get; set; }

    public string NameEn { get; set; } = null!;

    public string NameAr { get; set; } = null!;

    public string TemplateEn { get; set; } = null!;

    public string TemplateAr { get; set; } = null!;

    public DateTime? ModifiedAt { get; set; }

    public int? ModifiedBy { get; set; }

    public virtual ICollection<AssetHistory> AssetHistories { get; set; } = new List<AssetHistory>();

    public virtual AppUser? ModifiedByNavigation { get; set; }
}
