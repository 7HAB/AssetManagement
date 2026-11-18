using System;
using System.Collections.Generic;
using System.Text;

namespace AssetManagement.Application.Abstractions.Persistence;

public interface IRepository<TEntity> where TEntity : class
{
    /// <summary>
    /// Loads the entity TRACKED
    /// </summary>
    Task<TEntity?> GetForUpdateAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// True if a non-deleted row with this id exists (inactive rows still count).
    /// Used to validate incoming foreign-key ids before saving.
    /// </summary>
    Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>Stages a new entity. Nothing is written until IUnitOfWork.SaveChangesAsync.</summary>
    void Add(TEntity entity);
}