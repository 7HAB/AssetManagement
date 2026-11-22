using System;
using System.Collections.Generic;
using System.Text;

using AssetManagement.Application.Exceptions;

using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace AssetManagement.Infrastructure.Persistence;

/// <summary>
///  turns db failures into errors that can be explained to the client
///  if cannot be explained to the client then it is logged and a generic error is returned 500 
///  (for example fk violation because the service is supposed to catch that before it gets to the db)
///  if it can be explained to the client then an error code ir returned that can be used to display a message to the user
/// </summary>
internal static class DbExceptionTranslator
{
    private const int UniqueIndexViolation = 2601;       // our UX_ indexes
    private const int UniqueConstraintViolation = 2627;  // UNIQUE constraints / primary keys
    public static AppException? Translate(DbUpdateException exception) => exception switch
    {
        // Must come first: DbUpdateConcurrencyException IS a DbUpdateException,
        // so the general case below would otherwise swallow it.
        DbUpdateConcurrencyException => new ConflictException(
            ErrorCodes.Concurrency,
            "This record was changed by someone else after you loaded it. Reload it and try again.",
            exception),

        { InnerException: SqlException { Number: UniqueIndexViolation or UniqueConstraintViolation } } =>
            new ConflictException(
                ErrorCodes.Duplicate,
                "A record with the same unique value already exists.",
                exception),

        _ => null,
    };
}