using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using IWAServer.Models;
using IWAServer.Services;

namespace IWAServer.SendService
{

    public class SendBady
    {

        public class Metric
        {
            public Metric(double ram, double cpu, double disk, double perda, double latence)
            {
                this.ram = ram == -1 ? null : ram;
                this.cpu = cpu == -1 ? null : cpu;
                this.disk = disk == -1 ? null : disk;
                this.perda = perda == -1 ? null : perda;
                this.latence = latence == -1 ? null : latence;
            }

            public double? ram { get; set; } = null;
            public double? cpu { get; set; } = null;
            public double? disk { get; set; } = null;
            public double? perda { get; set; } = null;
            public double? latence { get; set; } = null;
        }

        public SendBady(string id, double ram, double cpu, double disk, double perda, double latence)
        {
            this.id = id;
            this.value = new Metric(ram, cpu, disk, perda, latence);
            this.dataTime = DateTime.Now.ToString();
        }

        public string id { get; set; } = "";
        public string dataTime { get; set; } = "";
        public Metric value { get; set; }

    }

    public class SendService
    {
        public static bool sendServerStatus = false;
        public static async Task SendToServer(List<MaquinaMonitorada> maquinas)
        {
            Logger.Info("Iniciado comunicação com InfraWatch Server", true);

            var values = maquinas.Select(i => new SendBady(i.Id.ToString(), i.RamPercent, i.CpuPercent, i.DiskPercent, i.PerdaPacotes, i.PingMs)).ToList();

            if (values == null || values.Count == 0)
            {
                Logger.Warn("Nada para enviar. Lista vazia.", true);
                sendServerStatus = false;
                return;
            }

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    string url = "https://infrawatch-backend.onrender.com/api/integrations/agents";

                    string json = JsonSerializer.Serialize(values);
                    Console.WriteLine(json);

                    var content = new StringContent(json, Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.PostAsync(url, content);

                    if (response.IsSuccessStatusCode)
                    {
                        string responseString = await response.Content.ReadAsStringAsync();
                        Logger.Info("Envio bem-sucedido.", true);
                        sendServerStatus = true;
                    }
                    else
                    {
                        Logger.Error($"Falha ao enviar dados - Status: {(int)response.StatusCode} {response.ReasonPhrase}", true);
                        sendServerStatus = false;
                    }
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
