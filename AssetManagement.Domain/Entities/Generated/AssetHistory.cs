using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class AssetHistory
{
    public long AssetHistoryId { get; set; }

    public int AssetId { get; set; }

    public int EventTypeId { get; set; }

    public int? FromStatusId { get; set; }

    public int ToStatusId { get; set; }

    public int? FromEmployeeId { get; set; }

    public int? ToEmployeeId { get; set; }

    public int? FromDepartmentId { get; set; }

    public int? ToDepartmentId { get; set; }

    public int? FromLocationId { get; set; }

    public int ToLocationId { get; set; }

    public DateOnly EffectiveDate { get; set; }

    public string? Reason { get; set; }

    public string? Note { get; set; }

    public long? CorrectsHistoryId { get; set; }

    public int PerformedBy { get; set; }

    public DateTime RecordedAt { get; set; }

    public virtual Asset Asset { get; set; } = null!;

    public virtual AssetHistory? CorrectsHistory { get; set; }

    public virtual AssetEventType EventType { get; set; } = null!;

    public virtual Department? FromDepartment { get; set; }

    public virtual Employee? FromEmployee { get; set; }

    public virtual Location? FromLocation { get; set; }

    public virtual AssetStatus? FromStatus { get; set; }

    public virtual AssetHistory? InverseCorrectsHistory { get; set; }

    public virtual AppUser PerformedByNavigation { get; set; } = null!;

    public virtual Department? ToDepartment { get; set; }

    public virtual Employee? ToEmployee { get; set; }

    public virtual Location ToLocation { get; set; } = null!;

    public virtual AssetStatus ToStatus { get; set; } = null!;
}
