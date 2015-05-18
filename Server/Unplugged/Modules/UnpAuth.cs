using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Dynamic;

namespace UnServer
{
    using Network.Log;

    class UnpAuth : Network.UnpModule
    {
        // modulo per effettuare login/logout
        public UnpAuth(ILogger logger = null)
            : base("unpauth", logger)
            //: base(typeof(UnpAuth).Name, logger)
        {
        }

        public override void HandleAction(string actionName, dynamic actionData, Network.UnpSession fromSession)
        {
            switch (actionName)
            {
                case "login":
                    {
                        try
                        {
                            // qui ci andrebbe il controllo delle credenziali e l'inserimento dei dati dell'utente
                            fromSession.DisplayName = actionData.username;
                            fromSession.Color = UnpUtils.GetRandomCssColor();

                            // imposto la sessione come loggata
                            fromSession.DidLogin = true;

                            // mando un messaggio di ok al client
                            Network.UnpMessage _cMessage = new Network.UnpMessage();
                            dynamic _result = new ExpandoObject();

                            _result.status = "ok";

                            _cMessage.AddAction(this.Name, "login-result", _result);
                            _cMessage.Send(fromSession.SessionId);

                            // richiamo la gestione del login su tutti i moduli
                            Network.UnpModuleManager.HandleLogin(fromSession);
                        }
                        catch (Exception exc)
                        {
                            Logger.Log(LogLevel.Error, this, "Login error: {0}", exc.ToString());
                            throw;
                        }
                    }
                    break;
                case "logout":
                    {
                        try
                        {
                            fromSession.DisplayName = string.Empty;
                            fromSession.Color = string.Empty;

                            // imposto la sessione come non loggata
                            fromSession.DidLogin = false;

                            // mando un messaggio di ok al client
                            Network.UnpMessage _cMessage = new Network.UnpMessage();
                            dynamic _result = new ExpandoObject();

                            _result.status = "ok";

                            _cMessage.AddAction(this.Name, "logout-result", _result);
                            _cMessage.Send(fromSession.SessionId);

                            // richiamo la gestione del logout su tutti i moduli
                            Network.UnpModuleManager.HandleLogout(fromSession);
                        }
                        catch (Exception exc)
                        {
                            Logger.Log(LogLevel.Error, this, "Logout error: {0}", exc.ToString());
                            throw;
                        }
                    }
                    break;
            }

        }

        public override void Dispose()
        {
        }
    }
}
