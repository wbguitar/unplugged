using Microsoft.Practices.Unity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UnServer.Network.Log
{
    
    [Flags]
    public enum LogLevel: int
    {
        Debug = 0x00000001,
        Trace = 0x00000010,
        Info = 0x00000100,
        Error = 0x00001000,
        None = 0x00010000,
    }

    public interface ILogger
    {
        LogLevel Filter { get; set; }
        void Log(LogLevel ll, object sender, string format, params object[] arg);
        void Log(LogLevel ll, object sender, string msg);
        //void Log(LogLevel ll, string format, params object[] arg);
        //void Log(LogLevel ll, string msg);
    }

    public interface IWriter
    {
        void Write(string msg);
    }

    public abstract class BLogger : ILogger
    {
        public LogLevel Filter { get; set; }

        class DefaultWriter : IWriter
        {
            public void Write(string msg)
            {
                System.Diagnostics.Debug.WriteLine(msg);
            }
        }

        IWriter writer;
        public BLogger(IWriter _writer)
        {
            if (_writer == null)
            {
                _writer = new DefaultWriter();
                _writer.Write("Null writer, using default System.Diagnostics.Debug");
                return;
            }

            writer = _writer;
        }

        public void Log(LogLevel ll, object sender, string format, params object[] arg)
        {
            if (!Filter.HasFlag(ll))
                return;

            var msg = format;
            try
            {
                msg = arg == null ?
                    format :
                    string.Format(format, arg);
            }
            catch (FormatException)
            {
                msg = format;
            }

            msg = string.Format("{0} - {1} [{2}]: {3}", ll, DateTime.Now, sender.GetType().Name, msg);

            if (writer != null)
                writer.Write(msg);
        }

        public void Log(LogLevel ll, object sender, string msg)
        {
            Log(ll, sender, msg, null);
        }
    }

    public class ConsoleLogger : BLogger
    {
        class ConsoleWriter : IWriter
        {
            public void Write(string msg)
            {
                Console.WriteLine(msg);
            }
        }

        public ConsoleLogger()
            : base(new ConsoleWriter())
        { }
    }

    public class LogManager
    {
        public static ILogger Logger { get; private set; }
        static Properties.Settings props = Properties.Settings.Default;

        static LogManager()
        {
            Logger = Globals.Ioc.Resolve<ILogger>();
            ResetFilter();

            //// carico le proprietà
            //if (props.LogLevels != null && props.LogLevels.Count > 0)
            //{
            //    Logger.Filter = new LogLevel();
            //    foreach (string ll in props.LogLevels)
            //    {
            //        Logger.Filter |= (LogLevel)Enum.Parse(typeof(LogLevel), ll);
            //    }
            //}
        }

        public static void ResetFilter()
        {
            Logger.Filter = LogLevel.Error | LogLevel.Info | LogLevel.Debug | LogLevel.Trace;
        }

        public static void Dispose()
        {
            //// salvo le proprietà
            //props.LogLevels = new System.Collections.ArrayList();
            //foreach (LogLevel ll in Enum.GetValues(typeof(LogLevel)))
            //{
            //    if (Logger.Filter.HasFlag(ll))
            //        props.LogLevels.Add(ll.ToString());
            //}
            //props.Save();
        }
    }

}
