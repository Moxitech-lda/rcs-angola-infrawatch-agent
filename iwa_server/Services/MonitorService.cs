using IWAServer.Models;
using System.Management;
using System.Net.NetworkInformation;

namespace IWAServer.Services
{
    public class PingStats
    {
        public string Status { get; set; } = "Offline";
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
                Status = sucesso > 0 ? "Online" : "Offline",
                LatenciaMediaMs = media,
                PerdaPacotesPercent = perda
            };
        }

        private double GetCpuUsage()
        {
            using var searcher = new ManagementObjectSearcher("select LoadPercentage from Win32_Processor");
            foreach (var obj in searcher.Get())
            {
                return Convert.ToDouble(obj["LoadPercentage"]);
            }
            return -1;
        }

        private double GetRamUsage()
        {
            using var searcher = new ManagementObjectSearcher("select TotalVisibleMemorySize, FreePhysicalMemory from Win32_OperatingSystem");
            foreach (var obj in searcher.Get())
            {
                double total = Convert.ToDouble(obj["TotalVisibleMemorySize"]);
                double free = Convert.ToDouble(obj["FreePhysicalMemory"]);
                return ((total - free) / total) * 100.0;
            }
            return -1;
        }

        private double GetDiskUsage()
        {
            using var searcher = new ManagementObjectSearcher("select FreeSpace, Size from Win32_LogicalDisk where DriveType=3");
            double usedPercent = 0;
            int count = 0;

            foreach (var obj in searcher.Get())
            {
                double size = Convert.ToDouble(obj["Size"]);
                double free = Convert.ToDouble(obj["FreeSpace"]);
                if (size > 0)
                {
                    usedPercent += ((size - free) / size) * 100.0;
                    count++;
                }
            }
            return count > 0 ? usedPercent / count : -1;
        }

        public MaquinaMonitorada ColetarMetricas(Machine machine)
        {
            var result = new MaquinaMonitorada
            {
                Id = machine.Id,
                Nome = machine.Nome,
                IP = machine.IP,
                TipoMonitoramento = machine.TipoMonitoramento.ToString(),
                TipoDispositivo = machine.TipoDispositivo.ToString()
            };

            if (machine.TipoMonitoramento == TipoMonitoramento.PING)
            {
                var stats = CalcularPingStats(machine.IP);

                result.Status = stats.Status;
                result.PingMs = stats.LatenciaMediaMs >= 0 ? (int)stats.LatenciaMediaMs : -1;
                result.PerdaPacotes = stats.PerdaPacotesPercent;
                result.CpuPercent = -1;
                result.RamPercent = -1;
                result.DiskPercent = -1;
            }

            else if (machine.TipoMonitoramento == TipoMonitoramento.WMI)
            {
                try
                {
                    result.Status = "Online";
                    result.PingMs = -1;
                    result.PerdaPacotes = -1;
                    result.CpuPercent = GetCpuUsage();
                    result.RamPercent = GetRamUsage();
                    result.DiskPercent = GetDiskUsage();
                }
                catch (Exception ex)
                {
                    result.Status = "Offline";
                    result.PingMs = -1;
                    result.PerdaPacotes = -1;
                    result.CpuPercent = -1;
                    result.RamPercent = -1;
                    result.DiskPercent = -1;
                }
            }

            return result;
        }


    }
}


