using System;


namespace UnServer
{
    using Microsoft.Practices.Unity;
    using Network.Log;
    using Network;

    static class Globals
    {
        static UnityContainer ioc = new UnityContainer();
        public static UnityContainer Ioc
        {
            get
            {
                return ioc;
            }
        }
    }


    class Program
    {
        /// <summary> Initialize the application and start the Alchemy Websockets server </summary>
        /// <param name="args"></param>
        static void Main(string[] args)
        {

            AppDomain.CurrentDomain.FirstChanceException += CurrentDomain_FirstChanceException;
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;

            Globals.Ioc.RegisterType<ILogger, ConsoleLogger>();
            var logger = LogManager.Logger;

            var netWork = new Network.Network();

            var unpAuth = new UnpAuth();
            var unpChat = new UnpChat();
            var unpMoveIt = new UnpMoveIt();

            netWork.StartWebSocket();

            // Accept commands on the console and keep it alive
            var command = string.Empty;
            while (command != "exit")
            {
                command = Console.ReadLine();
            }

            netWork.StopWebSocket();

            LogManager.Dispose();
            UnpModuleManager.Dispose();
        }

        static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            Console.WriteLine("From {0} - unhandled exception: {1}", sender, e.ExceptionObject.ToString());
        }

        static void CurrentDomain_FirstChanceException(object sender, System.Runtime.ExceptionServices.FirstChanceExceptionEventArgs e)
        {
            Console.WriteLine("From {0} - first chance exception: {1}", sender, e.Exception.ToString());
        }
    }
}
