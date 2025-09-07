namespace IWAServer.Models
{
    public enum TipoMonitoramento { PING, snmp }
    // public enum TipoDispositivo { PC, Switch, AccessPoint, Router, Impressora, Servidor, phone }

    public class Machine
    {
        public string Id { get; set; }
        public string Nome { get; set; } = "";
        public string IP { get; set; } = "";
        public string? Usuario { get; set; }
        public string? Senha { get; set; }
        public TipoMonitoramento TipoMonitoramento { get; set; }
        public bool Ativo { get; set; }
        public string TipoDispositivo { get; set; } = "";
    }
}
