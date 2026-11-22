using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Exceptions;
/// <summary>
/// 422 input is semantically invalid a business rule was violated
/// </summary>

public sealed class BusinessRuleException(string code, string message)
    : AppException(code, message);
    


