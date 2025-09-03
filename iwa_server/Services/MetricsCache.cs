using System.Collections.Concurrent;
using IWAServer.Models;

namespace IWAServer.Services
{
    public class MetricsCache
    {
        private readonly ConcurrentDictionary<int, MaquinaMonitorada> _metrics = new();

        public void UpdateMetrics(MaquinaMonitorada m, int index) => _metrics[index] = m;

        public List<MaquinaMonitorada> GetAllMetrics() => _metrics.Values.ToList();
    }
}
