namespace IWAServer.Models
{
    public class MaquinaMonitorada
    {
        public string Id { get; set; }
        public string Nome { get; set; } = "";
        public string IP { get; set; } = "";
        public string TipoMonitoramento { get; set; } = "";
        public string TipoDispositivo { get; set; } = "";
        public double PerdaPacotes { get; set; }
        public string Status { get; set; } = "Offline";
        public double CpuPercent { get; set; }
        public double RamPercent { get; set; }
        public double DiskPercent { get; set; }
        public int PingMs { get; set; }
    }
}
