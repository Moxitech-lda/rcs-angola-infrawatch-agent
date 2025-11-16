using IWAServer.Models;
using System.Management;
using System.Net.NetworkInformation;

namespace IWAServer.Services
{
    public class PingStats
    {
        public string Status { get; set; } = "down";
        public double LatenciaMediaMs { get; set; }
        public double PerdaPacotesPercent { get; set; }
    }

    public class MonitorService
    {
        private PingStats CalcularPingStats(string ip, int tentativas = 10, int timeout = 1000)
        {
            using var ping = new Ping();

            int sucesso = 0;
            long somaLatencia = 0;

            for (int i = 0; i < tentativas; i++)
            {
                try
                {
                    var reply = ping.Send(ip, timeout);
                    if (reply.Status == IPStatus.Success)
                    {
                        sucesso++;
                        somaLatencia += reply.RoundtripTime;
                    }
                }
                catch
                {
                    // falha já conta como perda
                }
            }

            int falhas = tentativas - sucesso;
            double perda = (double)falhas / tentativas * 100;
            double media = sucesso > 0 ? (double)somaLatencia / sucesso : -1;

            return new PingStats
            {
                Status = sucesso > 0 ? "up" : "down",
                LatenciaMediaMs = media,
                PerdaPacotesPercent = perda
            };
        }

        public MaquinaMonitorada ColetarMetricas(Machine machine)
        {
            var result = new MaquinaMonitorada
            {
                Id = machine.Id,
                Nome = machine.Nome,
                IP = machine.IP,
                TipoMonitoramento = machine.TipoMonitoramento.ToString(),
                TipoDispositivo = machine.TipoDispositivo.ToString(),
                Syncronized = machine.Syncronized
            };

            if (machine.TipoMonitoramento == TipoMonitoramento.PING)
            {
                var stats = CalcularPingStats(machine.IP);

                result.Status = stats.Status;
                result.Latency = stats.LatenciaMediaMs >= 0 ? (int)stats.LatenciaMediaMs : -1;
                result.PacketLoss = stats.PerdaPacotesPercent;
                result.CpuPercent = -1;
                result.RamPercent = -1;
                result.DiskPercent = -1;
            }
            else if (machine.TipoMonitoramento == TipoMonitoramento.snmp)
            {
                var client = SnmpManager.GetClient(machine.IP, "public");
                result.Latency = -1;
                result.PacketLoss = -1;

                string os = client.DetectOS();
                if (os == "unknown")
                {
                    result.Status = "down";
                    result.CpuPercent = -1;
                    result.RamPercent = -1;
                    result.DiskPercent = -1;
                }
                else
                {
                    result.Status = "up";
                    result.CpuPercent = client.GetCpuUsage() ?? -1;
                    result.RamPercent = client.GetRamUsage() ?? -1;
                    result.DiskPercent = client.GetDiskUsage() ?? -1;
                }
            }

            return result;
        }
    }
}
