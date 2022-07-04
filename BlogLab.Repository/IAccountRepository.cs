using System;
using Microsoft.AspNetCore.Identity;
using BlogLab.Models.Account;
using System.Threading.Tasks;
using System.Threading;

namespace BlogLab.Repository {
    public interface IAccountRepository {

        public Task<IdentityResult> CreateAsync(ApplicationUserIdentity user, CancellationToken cancellationToken);
        public Task<ApplicationUserIdentity> GetByUsernameAsync(string normalizedUsername, CancellationToken cancellationToken);
    }
}
