using IWAServer.Data;
using IWAServer.Models;
using IWAServer.SendService;
using IWAServer.Services;
using System;
using System.Runtime.InteropServices;
//
var builder = WebApplication.CreateBuilder(args);

// Configura caminho do DB
string dbPath = @"C:\AgentInfraWatch\infra_watch.db";

// Registra dependências
builder.Services.AddSingleton(new ConfigRepository(dbPath));
builder.Services.AddSingleton(new MachineRepository(dbPath));
builder.Services.AddSingleton<MonitorService>();
builder.Services.AddSingleton<MetricsCache>();
builder.Services.AddHostedService<BackgroundCollector>();

var app = builder.Build();

// Endpoints da API
app.MapGet("/sendStatus", (MachineRepository repo) =>
{
    return SendService.sendServerStatus;
});

app.MapGet("/metrics", (MetricsCache cache) =>
{
    return cache.GetAllMetrics();
});

var lifetime = app.Lifetime;

lifetime.ApplicationStopping.Register(() =>
{
    Logger.Info("Agente InfraWatch está parando... liberando recursos.");
});

lifetime.ApplicationStopped.Register(() =>
{
    Logger.Info("Agente InfraWatch finalizado.");
});

try
{
    Logger.Info("Iniciando agente InfraWatch...");
    app.Run();
}
catch (Exception ex)
{
    Logger.Error($"Falha fatal: {ex}");
}
