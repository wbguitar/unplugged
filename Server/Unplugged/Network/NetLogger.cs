using System;

namespace UnServer.Network
{
    public static class NetLogger
    {
        // Per ora gestiamo l'output via Console
        public static void OnConnect(string log)
        {
            Console.WriteLine(log);
        }

        public static void OnSend(string log)
        {
            Console.WriteLine(log);
        }

        public static void OnReceive(string log)
        {
            Console.WriteLine(log);
        }

        public static void OnDisconnect(string log)
        {
            Console.WriteLine(log);
        }
    }
}
