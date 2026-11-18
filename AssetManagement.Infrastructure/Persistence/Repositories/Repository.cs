using System;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using System.Text;

using AssetManagement.Application.Abstractions.Persistence;

using Microsoft.EntityFrameworkCore;

namespace AssetManagement.Infrastructure.Persistence.Repositories;

//generic base for int keyed entities
internal class Repository<TEntity>(AssetManagementDbContext dbContext): IRepository<TEntity> where TEntity : class
{
    private readonly string _keyName = ResolveIntKeyName(dbContext);

    protected AssetManagementDbContext DbContext { get; } = dbContext;

    protected DbSet<TEntity> Set => DbContext.Set<TEntity>();

    public Task<TEntity?> GetForUpdateAsync(int id, CancellationToken cancellationToken = default) =>
        Set.FirstOrDefaultAsync(e => EF.Property<int>(e, _keyName) == id, cancellationToken);
    public Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default) => 
        Set.AnyAsync(e => EF.Property<int>(e, _keyName) == id, cancellationToken);

    public void Add(TEntity entity)
    {
        ArgumentNullException.ThrowIfNull(entity);
        Set.Add(entity);
    }

    private static string ResolveIntKeyName(AssetManagementDbContext dbContext)
    {
        var key = dbContext.Model.FindEntityType(typeof(TEntity))?.FindPrimaryKey()
            ?? throw new InvalidOperationException(
                $"{typeof(TEntity).Name} is not mapped as an entity with a primary key.");

        if (key.Properties.Count != 1 || key.Properties[0].ClrType != typeof(int))
        {
            throw new InvalidOperationException(
                $"{typeof(TEntity).Name} does not have a single int key. Give it a specific repository.");
        }

        return key.Properties[0].Name;
    }

}
