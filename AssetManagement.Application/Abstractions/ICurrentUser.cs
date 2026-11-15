using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Abstractions;

public interface ICurrentUser
{
    int? UserId { get; }
    bool IsAuthenticated { get; }
    bool IsAdmin { get; }
}
