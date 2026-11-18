using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Abstractions.Persistence;

public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Runs work that needs MORE than one SaveChangesAsync (or reads that depend on an earlier write)
    /// inside one explicit transaction. Commits if the work finishes; rolls back if it throws.
    /// If a transaction is already open, the work joins it instead of starting a second one.
    /// </summary>
    Task ExecuteInTransactionAsync(Func<CancellationToken, Task> work, CancellationToken cancellationToken = default);
}
