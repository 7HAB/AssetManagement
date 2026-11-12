using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Domain.Enums;

/// <summary>
/// Mirrors the fixed rows of dbo.Role. Values must equal the database IDs.
/// </summary>
public enum RoleId
{
    Admin = 1,
    User = 2
} 