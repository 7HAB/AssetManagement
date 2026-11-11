using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Domain.Enums;

/// <summary>
/// Mirrors the fixed rows of dbo.AssetEventType. Values must equal the database IDs.
/// </summary>
public enum AssetEventTypeId
{
    Initial = 1,
    Transfer = 2,
    StatusChange = 3,
    Correction = 4,
    HolderDepartmentChange = 5
}