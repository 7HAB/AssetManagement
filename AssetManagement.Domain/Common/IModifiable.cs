using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Domain.Common;

public interface IModifiable
{
    DateTime? ModifiedAt { get; set; }
    int? ModifiedBy { get; set; }
}
