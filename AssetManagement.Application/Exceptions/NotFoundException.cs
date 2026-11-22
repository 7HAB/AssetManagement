using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Exceptions;
/// <summary>
///404 Not Found
/// </summary>

public sealed class NotFoundException(string entityName, object key) : AppException(ErrorCodes.NotFound, $"Entity \"{entityName}\" ({key}) was not found.");
