using System;
using System.IO;

namespace IWAServer.Services
{
    public static class Logger
    {
        private static string BasePath = @"C:\AgentInfraWatch\Logs";

        private static string GetLogPath(bool byServer)
        {
            var today = DateTime.Now.ToString("yyyy-MM-dd");
            Directory.CreateDirectory(BasePath);

            return byServer ? Path.Combine(BasePath, $"communication-server-{today}.log") : Path.Combine(BasePath, $"local-monitoring-{today}.log");
        }

        private static void Write(string level, string message, bool byServer)
        {
            try
            {
                var logPath = GetLogPath(byServer);
                var line = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} [{level}] {message}";
                File.AppendAllText(logPath, line + Environment.NewLine);

            }
            catch
            {

            }
        }

        public static void Info(string msg, bool byServer = false) => Write("INFO", msg, byServer);
        public static void Warn(string msg, bool byServer = false) => Write("WARN", msg, byServer);
        public static void Error(string msg, bool byServer = false) => Write("ERROR", msg, byServer);
    }
}
