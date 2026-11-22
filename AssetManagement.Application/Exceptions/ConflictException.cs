using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Exceptions;
/// <summary>
///409 request clashed woth other data concurrently modified by another user, 
///or a unique constraint was violated. caller should reload and try again
/// </summary>
public sealed class ConflictException(string code, string message, Exception? innerException = null)
    : AppException(code, message, innerException);
