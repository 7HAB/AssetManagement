using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Exceptions;
/// <summary>
/// fixed codes sent to client as ProblemDetails code
/// </summary>
public static class ErrorCodes
{
    public const string NotFound = "not_found";
    public const string Validation = "validation_failed";
    public const string Concurrency = "concurrency_conflict";
    public const string Duplicate = "duplicate_value";
}
