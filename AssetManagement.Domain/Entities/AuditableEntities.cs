using System;
using System.Collections.Generic;
using System.Text;

using AssetManagement.Domain.Common;

namespace AssetManagement.Domain.Entities;

public partial class Category : IAuditable { }
public partial class AssetType : IAuditable { }
public partial class Manufacturer : IAuditable { }
public partial class Currency : IAuditable { }
public partial class Department : IAuditable { }
public partial class Location : IAuditable { }
public partial class Employee : IAuditable { }
public partial class Asset : IAuditable { }
public partial class AppUser : IAuditable { }

public partial class AssetStatus : IModifiable { }
public partial class AssetEventType : IModifiable { }