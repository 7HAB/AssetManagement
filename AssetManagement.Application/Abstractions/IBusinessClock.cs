using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Abstractions;

public interface IBusinessClock
{
    DateTime UtcNow { get; }
    DateOnly Today { get; }
}
