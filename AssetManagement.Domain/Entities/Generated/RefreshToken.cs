using System;
using System.Collections.Generic;

namespace AssetManagement.Domain.Entities;

public partial class RefreshToken
{
    public long RefreshTokenId { get; set; }

    public int UserId { get; set; }

    public byte[] TokenHash { get; set; } = null!;

    public DateTime ExpiresAt { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? RevokedAt { get; set; }

    public long? ReplacedByTokenId { get; set; }

    public virtual ICollection<RefreshToken> InverseReplacedByToken { get; set; } = new List<RefreshToken>();

    public virtual RefreshToken? ReplacedByToken { get; set; }

    public virtual AppUser User { get; set; } = null!;
}
