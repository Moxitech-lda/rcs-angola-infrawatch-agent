namespace IWAServer.Models
{
    public class MaquinaMonitorada
    {
        public string Id { get; set; } = "";
        public string Nome { get; set; } = "";
        public string IP { get; set; } = "";
        public string TipoMonitoramento { get; set; } = "";
        public string TipoDispositivo { get; set; } = "";
        public string Status { get; set; } = "down";
        public double CpuPercent { get; set; }
        public double RamPercent { get; set; }
        public double DiskPercent { get; set; }
        public bool Syncronized { get; set; }

        public string LastCheck { get; set; } = DateTime.Now.ToString();
        public int UptimePercent { get; set; }
        public int DowntimeMinutes { get; set; }
        public int SlaPercent { get; set; }
        public double PacketLoss { get; set; }
        public double Latency { get; set; }


    }
}

