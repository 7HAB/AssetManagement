namespace AssetManagement.API.ErrorHandling;

internal static class ErrorHandlingExtensions
{
    public static IServiceCollection AddApiErrorHandling(this IServiceCollection services)
    {
        // Registers IProblemDetailsService (writes ProblemDetails JSON, fills type and traceId).
        services.AddProblemDetails(options =>
            options.CustomizeProblemDetails = context =>
                context.ProblemDetails.Instance ??= context.HttpContext.Request.Path);

        services.AddExceptionHandler<GlobalExceptionHandler>();

        return services;
    }

    public static WebApplication UseApiErrorHandling(this WebApplication app)
    {
        // Must be the FIRST middleware: it only catches exceptions from what comes after it.
        app.UseExceptionHandler();

        // Turns empty-body error responses (unknown URL 404, wrong verb 405) into ProblemDetails too.
        app.UseStatusCodePages();

        return app;
    }
}