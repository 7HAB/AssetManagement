using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Domain.Enums;

/// <summary>
/// Mirrors the fixed rows of dbo.AssetStatus. Values must equal the database IDs.
/// </summary>
public enum AssetStatusId
{
    Available = 1,
    Assigned = 2,
    UnderMaintenance = 3,
    Retired = 4
}