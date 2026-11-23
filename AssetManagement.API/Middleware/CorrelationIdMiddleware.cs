using System.Text.RegularExpressions;

using Serilog.Context;

namespace AssetManagement.API.Middleware;

/// <summary>
/// Gives every request a correlation id, stamps it on every log line written
/// during the request, and returns it to the caller in a response header.
/// </summary>
public sealed partial class CorrelationIdMiddleware
{
    public const string HeaderName = "X-Correlation-ID";

    private readonly RequestDelegate _next;

    public CorrelationIdMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = ResolveCorrelationId(context.Request);

        // For code that needs the value later in this request (e.g. the exception handler).
        context.Items[HeaderName] = correlationId;

        // Runs at the last safe moment, just before the response headers are sent.
        context.Response.OnStarting(() =>
        {
            context.Response.Headers[HeaderName] = correlationId;
            return Task.CompletedTask;
        });

        // For log lines: every event written inside this block carries CorrelationId.
        using (LogContext.PushProperty("CorrelationId", correlationId))
        {
            await _next(context);
        }
    }

    private static string ResolveCorrelationId(HttpRequest request)
    {
        if (request.Headers.TryGetValue(HeaderName, out var values)
            && values.Count == 1
            && values[0] is { } candidate
            && ValidIdRegex().IsMatch(candidate))
        {
            return candidate;
        }

        return Guid.NewGuid().ToString("N");
    }

    // Letters, digits, '-' and '_', 8 to 64 characters. \z = the true end of the string.
    [GeneratedRegex(@"^[A-Za-z0-9_-]{8,64}\z")]
    private static partial Regex ValidIdRegex();
}

public static class HttpContextCorrelationExtensions
{
    /// <summary>Returns this request's correlation id, or null if the middleware has not run.</summary>
    public static string? GetCorrelationId(this HttpContext context) =>
        context.Items.TryGetValue(CorrelationIdMiddleware.HeaderName, out var value)
            ? value as string
            : null;
}