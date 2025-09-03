namespace IWAServer.Models;

public class Config
{
    public string ServerUrl { get; set; } = "http://localhost:5000";
    public int CheckIntervalSeconds { get; set; } = 30; // tempo em segundos
}
