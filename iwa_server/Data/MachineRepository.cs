using System;
using System.Collections.Generic;
using Microsoft.Data.Sqlite;
using IWAServer.Models;

namespace IWAServer.Data
{
    public class MachineRepository
    {
        private readonly string _connectionString;

        public MachineRepository(string dbPath)
        {
            _connectionString = $"Data Source={dbPath}";
        }

        public List<Machine> GetAllMachines()
        {
            var list = new List<Machine>();
            using var conn = new SqliteConnection(_connectionString);
            conn.Open();

            using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM Machines;";

            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                list.Add(new Machine
                {

                    Id = reader.GetString(0),
                    Nome = reader.GetString(1),
                    IP = reader.GetString(2),
                    Usuario = reader.IsDBNull(3) ? null : reader.GetString(3),
                    Senha = reader.IsDBNull(4) ? null : reader.GetString(4),
                    TipoMonitoramento = (TipoMonitoramento)Enum.Parse(typeof(TipoMonitoramento), reader.GetString(5)),
                    Ativo = reader.GetInt32(6) == 1,
                    Syncronized = reader.GetInt32(7) == 1,
                    TipoDispositivo = reader.GetString(8),
                });
            }

            return list;
        }
    }
}