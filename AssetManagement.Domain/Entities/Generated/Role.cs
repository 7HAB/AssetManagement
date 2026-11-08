using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class Role
{
    public int RoleId { get; set; }

    public string NameEn { get; set; } = null!;

    public string NameAr { get; set; } = null!;

    public virtual ICollection<AppUser> AppUsers { get; set; } = new List<AppUser>();
}
