using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Domain.Common;

public interface IAuditable : IModifiable
{
    DateTime CreatedAt { get; set; }
    int CreatedBy { get; set; }
}
