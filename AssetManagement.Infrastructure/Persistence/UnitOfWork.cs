using System;
using System.Collections.Generic;
using System.Text;

using AssetManagement.Application.Abstractions.Persistence;

using Microsoft.EntityFrameworkCore;

namespace AssetManagement.Infrastructure.Persistence;

internal sealed class UnitOfWork(AssetManagementDbContext dbContext) : IUnitOfWork
{
    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            return await dbContext.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException ex) when (DbExceptionTranslator.Translate(ex) is { } translated)
        {
            throw translated;
        }
    }

    public async Task ExecuteInTransactionAsync(Func<CancellationToken, Task> work, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(work);

        //if already in a transaction
        //run the work and let the outer transaction handle commit/rollback
        if (dbContext.Database.CurrentTransaction is not null)
        {
            await work(cancellationToken);
            return;
        }

        await using var transaction = await dbContext.Database.BeginTransactionAsync(cancellationToken);
        await work(cancellationToken);
        await transaction.CommitAsync(cancellationToken);
    }
}
