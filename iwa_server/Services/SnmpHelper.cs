using SnmpSharpNet;
using System;
using System.Collections.Concurrent;
using System.Net;

namespace IWAServer.Services
{
    public class SnmpClient : IDisposable
    {
        private readonly string _ip;
        private readonly string _community;
        private readonly int _timeoutMs;
        private readonly UdpTarget _target;
        private readonly AgentParameters _param;

        public SnmpClient(string ip, string community = "public", int timeoutMs = 2000)
        {
            _ip = ip;
            _community = community;
            _timeoutMs = timeoutMs;
            _target = new UdpTarget(IPAddress.Parse(ip), 161, timeoutMs, 1);
            _param = new AgentParameters(SnmpVersion.Ver2, new OctetString(community));
        }

        public void Dispose()
        {
            _target?.Close();
        }

        /// <summary>
        /// Executa uma query SNMP com retry e retorna o valor bruto ou null se falhar
        /// </summary>
        public string GetRawValue(string oid, int retries = 2)
        {
            for (int attempt = 0; attempt <= retries; attempt++)
            {
                try
                {
                    var pdu = new Pdu(PduType.Get);
                    pdu.VbList.Add(oid);

                    var result = (SnmpV2Packet)_target.Request(pdu, _param);

                    if (result != null && result.Pdu.ErrorStatus == 0)
                        return result.Pdu.VbList[0].Value.ToString();
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[SNMP] Erro {ex.Message} ao consultar {oid} em {_ip}, tentativa {attempt + 1}");
                }
            }
            return null;
        }

        public double? GetValue(string oid)
        {
            var raw = GetRawValue(oid);
            if (raw == null) return null;

            if (double.TryParse(raw, out double value))
                return value;

            // Para o caso de strings com % ou outros caracteres
            raw = raw.Replace("%", "").Trim();
            return double.TryParse(raw, out value) ? value : null;
        }

        public string DetectOS()
        {
            var sysDescr = GetRawValue("1.3.6.1.2.1.1.1.0");
            if (string.IsNullOrEmpty(sysDescr)) return "unknown";

            sysDescr = sysDescr.ToLower();
            if (sysDescr.Contains("windows")) return "windows";
            if (sysDescr.Contains("linux") || sysDescr.Contains("ubuntu") || sysDescr.Contains("debian"))
                return "linux";

            return "unknown";
        }

        public double? GetCpuUsage()
        {
            var os = DetectOS();

            if (os == "linux")
                return GetValue("1.3.6.1.4.1.2021.11.9.0"); // UCD-SNMP: laLoad
            else if (os == "windows")
                return GetValue("1.3.6.1.2.1.25.3.3.1.2.1"); // HOST-RESOURCES-MIB

            return null;
        }

        public double? GetRamUsage()
        {
            var os = DetectOS();

            if (os == "linux")
            {
                var total = GetValue("1.3.6.1.4.1.2021.4.5.0");
                var free = GetValue("1.3.6.1.4.1.2021.4.6.0");
                if (total.HasValue && free.HasValue && total.Value > 0)
                    return ((total.Value - free.Value) / total.Value) * 100.0;
            }
            else if (os == "windows")
            {
                var total = GetValue("1.3.6.1.2.1.25.2.2.0");
                var used = GetValue("1.3.6.1.2.1.25.2.3.1.6.1");
                if (total.HasValue && used.HasValue && total.Value > 0)
                    return (used.Value / total.Value) * 100.0;
            }

            return null;
        }

        public double? GetDiskUsage()
        {
            var os = DetectOS();

            if (os == "linux")
            {
                var total = GetValue("1.3.6.1.4.1.2021.9.1.6.1");
                var free = GetValue("1.3.6.1.4.1.2021.9.1.7.1");
                if (total.HasValue && free.HasValue && total.Value > 0)
                    return ((total.Value - free.Value) / total.Value) * 100.0;
            }
            else if (os == "windows")
            {
                var used = GetValue("1.3.6.1.2.1.25.2.3.1.6.1");
                var total = GetValue("1.3.6.1.2.1.25.2.3.1.5.1");
                if (total.HasValue && used.HasValue && total.Value > 0)
                    return (used.Value / total.Value) * 100.0;
            }

            return null;
        }
    }

    /// <summary>
    /// Gerencia múltiplos clientes SNMP para evitar criar sockets repetidamente
    /// </summary>
    public static class SnmpManager
    {
        private static readonly ConcurrentDictionary<string, SnmpClient> _clients = new();

        public static SnmpClient GetClient(string ip, string community = "public")
        {
            return _clients.GetOrAdd(ip, _ => new SnmpClient(ip, community));
        }

        public static void DisposeAll()
        {
            foreach (var client in _clients.Values)
                client.Dispose();
            _clients.Clear();
        }
    }
}
