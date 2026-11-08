using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class PasswordResetToken
{
    public long PasswordResetTokenId { get; set; }

    public int UserId { get; set; }

    public byte[] TokenHash { get; set; } = null!;

    public DateTime ExpiresAt { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UsedAt { get; set; }

    public virtual AppUser User { get; set; } = null!;
}
