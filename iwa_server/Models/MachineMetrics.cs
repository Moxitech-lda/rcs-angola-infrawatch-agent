namespace IWAServer.Models
{
    public class MachineMetrics
    {
        public string MachineId { get; set; }
        public string Nome { get; set; } = "";
        public string IP { get; set; } = "";
        public double CpuUsage { get; set; }
        public double MemoryUsage { get; set; }
        public double DiskUsage { get; set; }
        public bool Reachable { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
