using System;
using Microsoft.Data.Sqlite;

namespace IWAServer.Data
{
    public class ConfigRepository
    {
        private readonly string _connectionString;

        public ConfigRepository(string dbPath)
        {
            _connectionString = $"Data Source={dbPath}";
        }

        public string? GetConfig(string key)
        {
            try
            {
                using var conn = new SqliteConnection(_connectionString);
                conn.Open();

                using var cmd = conn.CreateCommand();
                cmd.CommandText = "SELECT Value FROM Configs WHERE Key = @k LIMIT 1;";
                cmd.Parameters.AddWithValue("@k", key);

                var result = cmd.ExecuteScalar();
                return result?.ToString();
            }
            catch
            {
                return null;
            }
        }
    }
}
