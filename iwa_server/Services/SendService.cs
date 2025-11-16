using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using IWAServer.Data;
using IWAServer.Models;
using IWAServer.Services;


namespace IWAServer.SendService
{
    public class MachineStatusTracker
    {
        public int TotalChecks { get; private set; } = 0;
        public int UpChecks { get; private set; } = 0;
        public double DowntimeMinutes { get; private set; } = 0;

        private DateTime lastCheckTime;
        private string? lastStatus = null;

        public void RegisterCheck(MaquinaMonitorada maquina, TimeSpan checkInterval)
        {
            TotalChecks++;
            lastCheckTime = DateTime.Now;

            if (lastStatus == "up" && maquina.Status == "down")
            {
                //ShowdownNotification(maquina);
            }

            if (maquina.Status == "up")
                UpChecks++;
            else
                DowntimeMinutes += checkInterval.TotalMinutes;

            lastStatus = maquina.Status;
        }

        public int GetUptimePercent()
        {
            if (TotalChecks == 0) return 100;
            return (int)Math.Round((double)UpChecks * 100 / TotalChecks);
        }

        public string GetLastCheck()
        {
            return lastCheckTime.ToString("yyyy-MM-dd HH:mm:ss");
        }

        public int GetDowntimeMinutes()
        {
            return (int)Math.Round(DowntimeMinutes);
        }
    }

    public class SendBady
    {
        public class Metric
        {
            public Metric(double ram, double cpu, double disk, double packetLoss, double latency)
            {
                this.ram = ram == -1 ? null : ram;
                this.cpu = cpu == -1 ? null : cpu;
                this.disk = disk == -1 ? null : disk;
                this.packetLoss = packetLoss == -1 ? null : packetLoss;
                this.latency = latency == -1 ? null : latency;
            }

            public double? ram { get; set; }
            public double? cpu { get; set; }
            public double? disk { get; set; }
            public double? packetLoss { get; set; }
            public double? latency { get; set; }
        }

        public SendBady(string system_id, string status, string last_check, int uptime_percent, int downtime_minutes, double ram, double cpu, double disk, double packetLoss, double latency)
        {
            this.system_id = system_id;
            this.status = status;
            this.last_check = last_check;
            this.uptime_percent = uptime_percent;
            this.downtime_minutes = downtime_minutes;
            this.sla_percent = 0;
            this.value = new Metric(ram, cpu, disk, packetLoss, latency);
        }

        public string system_id { get; set; } = "";
        public string status { get; set; } = "";
        public string last_check { get; set; } = "";
        public int uptime_percent { get; set; } = 100;
        public int downtime_minutes { get; set; } = 0;
        public int sla_percent { get; set; } = 0;
        public Metric value { get; set; }
    }

    public class SendService
    {
        public static bool sendServerStatus = false;

        public static readonly Dictionary<string, MachineStatusTracker> trackers = new();

        public static async Task SendToServer(List<MaquinaMonitorada> maquinas)
        {
            //  Logger.Info("Iniciado comunicação com InfraWatch Server", true);

            var values = new List<SendBady>();

            foreach (var m in maquinas)
            {
                values.Add(new SendBady(
                    system_id: m.Id,
                    status: m.Status,
                    last_check: m.LastCheck,
                    uptime_percent: m.UptimePercent,
                    downtime_minutes: m.DowntimeMinutes, // isso aqui parece errado, confere
                    ram: m.RamPercent,
                    cpu: m.CpuPercent,
                    disk: m.DiskPercent,
                    packetLoss: m.PacketLoss,
                    latency: m.Latency
                ));
            }

            if (values.Count == 0)
            {
                Logger.Warn("Nada para enviar. Lista vazia.", true);
                sendServerStatus = false;
                return;
            }

            string dbPath = @"C:\AgentInfraWatch\infra_watch.db";
            var token = new ConfigRepository(dbPath).GetConfig("token");
            if (token == null)
            {
                Logger.Error("Token não encontrado no Config.", true);
                return;
            }

            string url = $"https://infrawatch-backend.onrender.com/api/integrations/agents/{token}/metrics";

            var options = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

            using (HttpClient client = new HttpClient())
            {
                foreach (var value in values)
                {
                    try
                    {
                        string json = JsonSerializer.Serialize(value, options);

                        var request = new HttpRequestMessage(new HttpMethod("PATCH"), url)
                        {
                            Content = new StringContent(json, Encoding.UTF8, "application/json")
                        };

                        var response = await client.SendAsync(request);

                        if (response.IsSuccessStatusCode)
                        {
                            Logger.Info(json, true);
                            Logger.Info($"Envio bem-sucedido ao servidor central.  Status: {(int)response.StatusCode}", true);
                            sendServerStatus = true;
                        }
                        else
                        {
                            Logger.Info(json, true);
                            Logger.Error($"Falha no envio - Status: {(int)response.StatusCode} {response.ReasonPhrase}", true);
                            sendServerStatus = false;
                        }
                    }
                    catch (Exception ex)
                    {
                        Logger.Error($"Exceção durante envio: {ex.Message}", true);
                        sendServerStatus = false;
                    }
                }
            }
        }


    }
}
