using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Exceptions;
/// <summary>
///base for every failure in the application, can be used to return a ProblemDetails response to the client
/// </summary>

public abstract class AppException(string code, string message, Exception? innerException = null) : Exception(message, innerException)
{
    public string Code { get; } = code;
}
