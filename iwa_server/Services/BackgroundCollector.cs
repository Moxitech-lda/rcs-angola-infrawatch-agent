using Microsoft.Extensions.Hosting;
using IWAServer.Data;
using IWAServer.Models;
using IWAServer.SendService;

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
                    foreach (var m in machines)
                    {
                        if (!SendService.SendService.trackers.ContainsKey(m.Id))
                            SendService.SendService.trackers[m.Id] = new MachineStatusTracker();

                        var metrics = _monitor.ColetarMetricas(m);

                        SendService.SendService.trackers[metrics.Id].RegisterCheck(metrics, new TimeSpan(0, 0, intervalo));
                        var tracker = SendService.SendService.trackers[m.Id];

                        metrics.LastCheck = tracker.GetLastCheck();
                        metrics.UptimePercent = tracker.GetUptimePercent();
                        metrics.DowntimeMinutes = tracker.GetDowntimeMinutes();
                        metrics.SlaPercent = 0;

                        _cache.UpdateMetrics(metrics, index++);


                        if (m.TipoMonitoramento == TipoMonitoramento.PING)
                            Logger.Info($"[{m.Nome}] Type: ping, Status={metrics.Status}, Packet_Loss={metrics.PacketLoss:F1}%, Latency={metrics.Latency:F1}ms Uptime={metrics.UptimePercent:F1}% Downtime={metrics.DowntimeMinutes:F1}min Last_Check={metrics.LastCheck:F1}");
                        else
                            Logger.Info($"[{m.Nome}] Type: snmp, Status={metrics.Status}, CPU={metrics.CpuPercent:F1}%, RAM={metrics.RamPercent:F1}%, Disk={metrics.DiskPercent:F1}%  Uptime={metrics.UptimePercent:F1}% Downtime={metrics.DowntimeMinutes:F1}min Last_Check={metrics.LastCheck:F1}");
                    }

                    _ = SendService.SendService.SendToServer(_cache.GetAllMetrics().Where(x => x.Syncronized).ToList());
                }
                catch (Exception ex)
                {
                    Logger.Error($"Erro no loop de coleta: {ex.Message}");
                }

                await Task.Delay(intervalo * 1000, stoppingToken);
            }
        }
    }

    public class SendBady
    {
        public string Status { get; set; } = "down";
        public double ram { get; set; } = -1;
        public double cpu { get; set; } = -1;
        public double disk { get; set; } = -1;
        public double perda { get; set; } = -1;
        public double latence { get; set; } = -1;
    }

}
