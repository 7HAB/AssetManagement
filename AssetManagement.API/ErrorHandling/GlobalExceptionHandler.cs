using AssetManagement.Application.Exceptions;

using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace AssetManagement.API.ErrorHandling;

/// <summary>
/// The ONE place that maps exceptions to HTTP. Every failure leaves the API as ProblemDetails.
/// AppException = expected: its message is safe to show. Anything else = bug: generic 500,
/// details only in the log. No stack traces, SQL or exception messages of unknown errors in responses.
/// </summary>
internal sealed class GlobalExceptionHandler(IProblemDetailsService problemDetailsService, ILogger<GlobalExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
    {
        var problem = CreateProblem(httpContext, exception);
        var status = problem.Status ?? StatusCodes.Status500InternalServerError;

        Log(httpContext, exception, status);

        if (exception is AppException appException)
        {
            problem.Extensions["code"] = appException.Code;
        }

        httpContext.Response.StatusCode = status;

        return await problemDetailsService.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = httpContext,
            ProblemDetails = problem,
        });
    }

    private static ProblemDetails CreateProblem(HttpContext httpContext, Exception exception) => exception switch
    {
        ValidationFailedException e => new HttpValidationProblemDetails(
            e.Errors.ToDictionary(pair => pair.Key, pair => pair.Value))
        {
            Status = StatusCodes.Status400BadRequest,
            Title = "Validation failed",
            Detail = e.Message,
        },

        NotFoundException e => Problem(StatusCodes.Status404NotFound, "Not found", e.Message),

        BusinessRuleException e => Problem(StatusCodes.Status422UnprocessableEntity, "Business rule violated", e.Message),

        ConflictException e => Problem(StatusCodes.Status409Conflict, "Conflict", e.Message),

        // Malformed request the framework itself rejected (e.g. unreadable body). Its status is already right.
        BadHttpRequestException e => Problem(e.StatusCode, "Bad request", null),

        // The caller closed the connection (tab closed, navigated away). Not our failure.
        OperationCanceledException when httpContext.RequestAborted.IsCancellationRequested =>
            Problem(StatusCodes.Status499ClientClosedRequest, "Request cancelled", null),

        // A bug. Never expose its message: it may contain SQL, connection details or internals.
        _ => Problem(StatusCodes.Status500InternalServerError, "An unexpected error occurred", null),
    };

    private static ProblemDetails Problem(int status, string title, string? detail) =>
        new() { Status = status, Title = title, Detail = detail };

    private void Log(HttpContext httpContext, Exception exception, int status)
    {
        var method = httpContext.Request.Method;
        var path = httpContext.Request.Path;

        switch (status)
        {
            case >= 500:
                // Full exception with stack trace: this is the one we must fix.
                logger.LogError(exception, "Unhandled exception for {Method} {Path}", method, path);
                break;

            case StatusCodes.Status409Conflict:
                // Include the exception: its InnerException holds the SQL Server detail (which index, which value).
                logger.LogWarning(exception, "Conflict for {Method} {Path}", method, path);
                break;

            case StatusCodes.Status499ClientClosedRequest:
                logger.LogInformation("Request cancelled by the client: {Method} {Path}", method, path);
                break;

            default:
                // Expected 4xx: one line, no stack trace. These are normal events, not problems.
                logger.LogInformation(
                    "Request failed with {StatusCode} ({ExceptionType}): {Method} {Path}",
                    status, exception.GetType().Name, method, path);
                break;
        }
    }
}