using System;
using System.Collections.Generic;
using System.Text;
using BlogLab.Models.Account;
using Microsoft.AspNetCore.Identity;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using System.Data;
using System.Data.SqlClient;
using Dapper;

namespace BlogLab.Repository {
    public class AccountRepository: IAccountRepository {

        private readonly IConfiguration _config;

        public AccountRepository ( IConfiguration config ) {

            _config = config;
        }

        public async Task<IdentityResult> CreateAsync ( ApplicationUserIdentity user ,
            CancellationToken cancellationToken ){ 
            
            cancellationToken.ThrowIfCancellationRequested();

            var dataTable = new DataTable();
            dataTable.Columns.Add( "Username", typeof(string));
            dataTable.Columns.Add ( "NormalizedUsername", typeof(string));
            dataTable.Columns.Add ("Email" , typeof (string));
            dataTable.Columns.Add ("NormalizedEmail" , typeof (string));
            dataTable.Columns.Add ("Fullname" , typeof (string));
            dataTable.Columns.Add ("PasswordHash" , typeof (string));

            dataTable.Rows.Add(
                
                user.Username,
                user.NormalizedUsername,
                user.Email,
                user.NormalizedEmail,
                user.Fullname,
                user.PasswordHash
            );

            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"))) {

                await connection.OpenAsync(cancellationToken);
                await connection.ExecuteScalarAsync("Account_Insert", new { Account = dataTable.AsTableValuedParameter("dbo.AccountType")}, commandType: CommandType.StoredProcedure );
            }

            return IdentityResult.Success;

        }

        public async Task<ApplicationUserIdentity> GetByUsernameAsync ( string normalizedUsername ,
            CancellationToken cancellationToken ){

            cancellationToken.ThrowIfCancellationRequested ( );

            ApplicationUserIdentity applicationUser;

            using (var connection = new SqlConnection(_config.GetConnectionString("DefaultConnection"))) {

                await connection.OpenAsync(cancellationToken);
                applicationUser = await connection.QuerySingleOrDefaultAsync<ApplicationUserIdentity>(
                    "Account_GetUsername", new { normalizedUsername = normalizedUsername},
                    commandType: CommandType.StoredProcedure
                );
            }

            return applicationUser;
        }
    }
}
