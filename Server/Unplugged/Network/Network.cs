using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using Alchemy;
using Alchemy.Classes;
using Newtonsoft.Json;
using UnServer.Mobiles;
using System.Collections;


namespace UnServer.Network
{
    using Log;
    using Microsoft.Practices.Unity;

    interface IUnpModule
    {
        // gestione delle richieste (da implementare nei vari moduli che ereditano)
        void HandleAction(string actionName, dynamic actionData, UnpSession fromSession);

        // gestione del login (da implementare nei vari moduli che ereditano)
        void HandleLogin(UnpSession fromSession);

        // gestione del logout (da implementare nei vari moduli che ereditano)
        void HandleLogout(UnpSession fromSession);
    }

    abstract class UnpModule: IUnpModule, IDisposable
    {
        // classe base per i moduli (chat, gioco...)
        public string Name = null;
        protected ILogger Logger { get; set; }

        public UnpModule(string name, ILogger _logger = null)
        {
            Name = name;

            Logger = _logger == null ?
                LogManager.Logger :
                _logger;

            // registro il modulo in modo che possa ricevere messaggi
            UnpModuleManager.RegisterModule(this);
        }

        public virtual void HandleAction(string actionName, dynamic actionData, UnpSession fromSession)
        {
            Logger.Log(LogLevel.Debug, this, "Handling action {0}, data = [{1}], session id {2}"
                , actionName, actionData == null ? null : actionData.ToString(), fromSession.SessionId);
        }

        public virtual void HandleLogin(UnpSession fromSession)
        {
            Logger.Log(LogLevel.Debug, "Handling login id {1}, name {2}"
                , fromSession.SessionId, fromSession.DisplayName);
        }

        public virtual void HandleLogout(UnpSession fromSession)
        {
            Logger.Log(LogLevel.Debug, "Handling logout id {1}, name {2}"
                , fromSession.SessionId, fromSession.DisplayName);
        }

        public abstract void Dispose();
    }

    class UnpModuleManager
    {
        public static ILogger Logger { get; set; }

        UnpModuleManager() { }
        static UnpModuleManager instance;

        static UnpModuleManager()
        {
            Logger = LogManager.Logger;
            instance = new UnpModuleManager();
        }

        // gestore dei moduli istanziati
        private Hashtable _ModuleList = new Hashtable();

        public static bool RegisterModule(UnpModule moduleObj)
        {
            if (instance._ModuleList.ContainsKey(moduleObj.Name))
                return false;
            // aggiungo il modulo alla lista per nome, in modo da poterlo individuare come "destinatario" dei messaggi
            instance._ModuleList.Add(moduleObj.Name, moduleObj);
            Logger.Log(LogLevel.Debug, instance, "Registering module {0}", moduleObj.Name);
            return true;
        }

        public static void HandleMessage(dynamic message, UserContext context)
        {
            UnpSession _cSession = UnpSessionManager.GetSessionByUserContext(context);

            Logger.Log(LogLevel.Debug, instance, "Handling message {0} from {1}", message.ToString(), context.ClientAddress);
            // per ogni azione presente nella richiesta, evoco il gestore del modulo appropriato
            for (int i = 0; i < message.unp.Count; i++)
            {
                dynamic _cAction = message.unp[i];
                string _moduleName = _cAction.module.Value;

                if (_moduleName == "unpauth" || _cSession.DidLogin)
                {
                    // faccio passare solo le richieste di chi si è già loggato o quelle dirette al modulo di login
                    UnpModule _cModule = instance._ModuleList[_moduleName] as UnpModule;
                    _cModule.HandleAction(_cAction.action.Value, _cAction.data, _cSession);
                }
                else
                {
                    Logger.Log(LogLevel.Info, instance, "Unauthorized address: {0}", context.ClientAddress);
                }
            }
        }

        public static void HandleLogin(UnpSession session)
        {
            Logger.Log(LogLevel.Info, instance, "Login: id {0}, name {1}", session.SessionId, session.DisplayName);
            // richiamo la handlelogin su tutti i moduli
            foreach (string _moduleName in instance._ModuleList.Keys)
            {
                UnpModule _cModule = instance._ModuleList[_moduleName] as UnpModule;
                _cModule.HandleLogin(session);
            }
        }

        public static void HandleLogout(UnpSession session)
        {
            Logger.Log(LogLevel.Info, instance, "Logout: id {0}, name {1}", session.SessionId, session.DisplayName);
            // richiamo la handlelogout su tutti i moduli
            foreach (string _moduleName in instance._ModuleList.Keys)
            {
                UnpModule _cModule = instance._ModuleList[_moduleName] as UnpModule;
                _cModule.HandleLogout(session);
            }
        }

        public static void Dispose()
        {
            foreach (var key in instance._ModuleList.Keys)
            {
                var item = instance._ModuleList[key];
                if (item != null && item is IDisposable)
                {
                    (item as IDisposable).Dispose();
                }
            }
        }
    }

    class UnpAction
    {
        public string ModuleName;
        public string ActionName;
        public dynamic ActionData;

        public UnpAction(string moduleName, string actionName, dynamic actionData)
        {
            ModuleName = moduleName;
            ActionName = actionName;
            ActionData = actionData;
        }
    }

    class UnpMessage
    {
        // classe per inviare i messaggi
        public string ModuleName = null;
        private ArrayList _ActionList = new ArrayList();

        public void AddAction(string moduleName, string actionName, dynamic actionData)
        {
            // aggiungo un'azione al messaggio
            _ActionList.Add(new UnpAction(moduleName, actionName, actionData));
        }

        public void Send(string user)
        {
            // invio il messaggio ad un singolo utente
            dynamic _msgObj = _BuildMessageFromActions();

            Network.Send(JsonConvert.SerializeObject(_msgObj), UnpSessionManager.GetUserContextBySessionId(user));
        }

        public void Broadcast(ICollection<string> users = null)
        {
            // invio il messaggio a tutti, con eventuale lista di destinatari (null = tutti)
            dynamic _msgObj = _BuildMessageFromActions();

            Network.Broadcast(JsonConvert.SerializeObject(_msgObj), UnpSessionManager.GetAllUserContextBySessionId(users));
        }

        private dynamic _BuildMessageFromActions()
        {
            // funzione helper per convertire in un json la lista delle action
            dynamic _retVal = new
            {
                unp = new ArrayList()
            };

            foreach (UnpAction _cAction in _ActionList)
            {
                dynamic _cObj = new
                {
                    module = _cAction.ModuleName,
                    action = _cAction.ActionName,
                    data = _cAction.ActionData
                };

                _retVal.unp.Add(_cObj);
            }

            return _retVal;
        }
    }

    class UnpSession
    {
        // oggetto della sessione
        // ora ho messo delle property qua dentro, andrebbero racchiuse in una classe user
        public bool DidLogin = false;
        public string DisplayName = string.Empty;
        public string Color = string.Empty;
        public string SessionId
        {
            get { return _SessionId; }
            set {}
        }

        private string _SessionId = string.Empty;

        public UnpSession()
        {
            _SessionId = Guid.NewGuid().ToString();
        }
    }

    static class UnpSessionManager
    {
        private static ConcurrentDictionary<UnpSession, UserContext> _OnlineUsers = new ConcurrentDictionary<UnpSession, UserContext>();

        public static void StartSession(UserContext context)
        {
            // inizio sessione: aggiungo una nuova sessione a quelle attive
            _OnlineUsers.TryAdd(new UnpSession(), context);
        }

        public static void EndSession(UserContext context)
        {
            // fine sessione: rimuovo la sessione da quelle attive
            UnpSession _contextKey = null;
            foreach (UnpSession _cKey in _OnlineUsers.Keys)
            {
                if (_OnlineUsers[_cKey].ClientAddress == context.ClientAddress)
                {
                    _contextKey = _cKey;
                    break;
                }
            }

            if (_contextKey != null)
            {
                if (_contextKey.DidLogin)
                {
                    // se aveva eseguito il login, richiamo la logout su tutti i moduli attivi
                    UnpModuleManager.HandleLogout(_contextKey);
                }

                UserContext outContext;
                _OnlineUsers.TryRemove(_contextKey, out outContext);
            }
        }

        public static UserContext GetUserContextBySessionId(string sessionId)
        {
             UnpSession _cKey = _OnlineUsers.Keys.Single(o => o.SessionId == sessionId);

             return _OnlineUsers[_cKey];
        }

        public static List<UserContext> GetAllUserContextBySessionId(ICollection<string> sessionId = null)
        {
            List<UserContext> _retVal = new List<UserContext>();

            if (sessionId == null)
            {
                foreach (var u in _OnlineUsers.Keys)
                {
                    if (u.DidLogin) _retVal.Add(_OnlineUsers[u]);
                }
            }
            else
            {
                foreach (var u in _OnlineUsers.Keys.Where(o => sessionId.Contains(o.SessionId)))
                {
                    if (u.DidLogin) _retVal.Add(_OnlineUsers[u]);
                }
            }

            return _retVal;
        }

        public static UnpSession GetSessionByUserContext(UserContext context)
        {
            UnpSession _retVal = null;

            foreach (UnpSession _cSession in _OnlineUsers.Keys)
            {
                if (_OnlineUsers[_cSession].ClientAddress == context.ClientAddress)
                {
                    _retVal = _cSession;
                    break;
                }
            }

            return _retVal;
        }
    }

    class Network
    {
        // variabile privata per l'apertura del socket di connessione
        private WebSocketServer aServer;

        static ILogger logger;

        public Network(ILogger _logger = null)
        {
            if (_logger == null)
                _logger = LogManager.Logger;

            logger = _logger;
        }

        /// <summary> Inizializza e fa partire il WebSocket Network </summary>
        public void StartWebSocket()
        {
            // Initialize the server on port 8080, accept any IPs, and bind events.
            aServer = new WebSocketServer(8080, IPAddress.Any)
            {
                OnReceive = OnReceive,
                OnSend = OnSend,
                OnConnected = OnConnect,
                OnDisconnect = OnDisconnect,
                TimeOut = new TimeSpan(0, 5, 0)
            };

            logger.Log(LogLevel.Info, this, "Starting WebSocketServer");
            aServer.Start();
        }

        /// <summary> Chiude il WebSocket Network </summary>
        public void StopWebSocket()
        {
            if (aServer != null)
            {
                logger.Log(LogLevel.Info, this, "Sopping WebSocketServer");
                aServer.Stop();
            }
        }

        /// <summary> Event fired when a client connects to the Alchemy Websockets server instance. Adds the client to the online users list. </summary>
        /// <param name="context">The user's connection context</param>
        public void OnConnect(UserContext context)
        {
            //NetLogger.OnConnect("Connect: " + context.ClientAddress);
            logger.Log(LogLevel.Info, this, "Client connected: {0}", context.ClientAddress);
            UnpSessionManager.StartSession(context);
        }

        /// <summary> Questo evento viene eseguito quanto Alchemy Websockets Server ha inviato qualcosa al context. </summary>
        /// <param name="context">The user's connection context</param>
        public void OnSend(UserContext context)
        {
            //NetLogger.OnSend("Send: " + context.ClientAddress);
            logger.Log(LogLevel.Debug, this, "Sending {0} to {1}", context.DataFrame, context.ClientAddress);
        }

        /// <summary>
        /// Event fired when a data is received from the Alchemy Websockets server instance.
        /// Parses data as JSON and calls the appropriate message or sends an error message.
        /// </summary>
        /// <param name="context">The user's connection context</param>
        public void OnReceive(UserContext context)
        {
            //NetLogger.OnReceive("Receive: " + context.ClientAddress);
            logger.Log(LogLevel.Debug, this, "Receiving {0} from {1}", context.DataFrame, context.ClientAddress);
            try
            {
                var json = context.DataFrame.ToString();
                dynamic obj = JsonConvert.DeserializeObject(json);

                // richiedo al gestore dei moduli di gestire il messaggio smistandolo tra i vari moduli presenti
                UnpModuleManager.HandleMessage(obj, context);
            }
            catch (Exception e) // Bad JSON! For shame.
            {
                //Console.WriteLine("Error (" + e.Message + "): " + context.ClientAddress);
                logger.Log(LogLevel.Error, this, e.ToString());
            }
        }

        /// <summary> Questo evento viene chiamato quando un client si disconnette. </summary>
        /// <param name="context">The user's connection context</param>
        public void OnDisconnect(UserContext context)
        {
            //NetLogger.OnDisconnect("Disconnect: " + context.ClientAddress);
            logger.Log(LogLevel.Info, this, "Disconnecting {0}", context);
            UnpSessionManager.EndSession(context);
        }
        
        /// <summary> Broadcasts a message to all users, or if users is populated, a select list of users </summary>
        /// <param name="message">Message to be broadcast</param>
        /// <param name="users">Optional list of users to broadcast to. If null, broadcasts to all. Defaults to null.</param>
        public static void Broadcast(string message, ICollection<UserContext> users = null)
        {
            logger.Log(LogLevel.Debug, "Broadcasting message: {0}", message);
            foreach (UserContext _uc in users)
            {
                _uc.Send(message);
            }
        }

        public static void Send(string message, UserContext user)
        {
            logger.Log(LogLevel.Debug, "Sending message {0} to user {1}", message, user);
            user.Send(message);
        }
    }
}
