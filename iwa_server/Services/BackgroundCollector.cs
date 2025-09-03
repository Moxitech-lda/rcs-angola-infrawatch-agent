using Microsoft.Extensions.Hosting;
using IWAServer.Data;
using IWAServer.Models;

namespace IWAServer.Services
{
    public class BackgroundCollector : BackgroundService
    {
        private readonly ConfigRepository _configRepo;
        private readonly MachineRepository _machineRepo;
        private readonly MonitorService _monitor;
        private readonly MetricsCache _cache;

        public BackgroundCollector(ConfigRepository configRepo, MachineRepository machineRepo, MonitorService monitor, MetricsCache cache)
        {
            _configRepo = configRepo;
            _machineRepo = machineRepo;
            _monitor = monitor;
            _cache = cache;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                int intervalo = 5;
                try
                {
                    var intervaloStr = _configRepo.GetConfig("frequence");

                    if (!string.IsNullOrEmpty(intervaloStr) && int.TryParse(intervaloStr, out var parsed))
                    {
                        intervalo = Math.Max(1, parsed);
                    }

                    var machines = _machineRepo.GetAllMachines();

                    Logger.Info($"Coletando métricas de {machines.Count} máquinas.");
                    int index = 0;
                    foreach (var m in machines.Where(x => x.Ativo))
                    {
                        var metrics = _monitor.ColetarMetricas(m);
                        _cache.UpdateMetrics(metrics, index++);

                        if (m.TipoMonitoramento == TipoMonitoramento.PING)
                            Logger.Info($"[{m.Nome}] Tipo: PING, Status={metrics.Status}, Perda={metrics.PerdaPacotes:F1}%, Latência={metrics.PingMs:F1}ms");
                        else
                            Logger.Info($"[{m.Nome}] Tipo: WMI, Status={metrics.Status}, CPU={metrics.CpuPercent:F1}%, RAM={metrics.RamPercent:F1}%, Disk={metrics.DiskPercent:F1}%");

                    }
                }
                catch (Exception ex)
                {
                    Logger.Error($"Erro no loop de coleta: {ex.Message}");
                }

                _ = SendService.SendService.SendToServer(_cache.GetAllMetrics());
                await Task.Delay(intervalo * 1000, stoppingToken);
            }
        }
    }

    public class SendBady
    {
        public string Status { get; set; } = "Offline";
        public double ram { get; set; } = -1;
        public double cpu { get; set; } = -1;
        public double disk { get; set; } = -1;
        public double perda { get; set; } = -1;
        public double latence { get; set; } = -1;
    }

}
