using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Exceptions;
/// <summary>
///400 Input is invalid. Errors are grouped by field so the form can show each one in place
/// </summary>
public sealed class ValidationFailedException(IReadOnlyDictionary<string, string[]> errors)
    : AppException(ErrorCodes.Validation, "One or more validation errors occurred.")
{
public ValidationFailedException(string field, string message): this(new Dictionary<string, string[]> { [field] = [message] })
    {
    }
    public IReadOnlyDictionary<string, string[]> Errors { get; } = errors;
}