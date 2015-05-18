using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Dynamic;

namespace UnServer
{
    using Network.Log;

    class UnpChat : Network.UnpModule
    {
        public UnpChat(ILogger logger = null)
            : base ("unpchat")
        {
        }

        public override void HandleAction(string actionName, dynamic actionData, Network.UnpSession fromSession)
        {
            switch (actionName)
            {
                case "message":
                    {
                        try
                        {
                            Network.UnpMessage _cMessage = new Network.UnpMessage();
                            dynamic _cActionData = new ExpandoObject();
                            _cActionData.from = fromSession.DisplayName;
                            _cActionData.color = fromSession.Color;
                            _cActionData.text = actionData.text;
                            _cMessage.AddAction(this.Name, "message", _cActionData);
                            _cMessage.Broadcast();
                        }
                        catch (Exception exc)
                        {
                            Logger.Log(LogLevel.Error, this, "Logout error: {0}", exc);
                            throw;
                        }
                    }
                    break;
            }

        }

        public override void HandleLogin(Network.UnpSession fromSession)
        {
            try
            {
                Network.UnpMessage _cMessage = new Network.UnpMessage();
                dynamic _cActionData = new ExpandoObject();
                _cActionData.text = fromSession.DisplayName + " has logged in";
                _cMessage.AddAction(this.Name, "sysmsg", _cActionData);
                _cMessage.Broadcast();
            }
            catch (Exception exc)
            {
                Logger.Log(LogLevel.Error, this, "Login error: {0}", exc);
                throw;
            }

        }

        public override void HandleLogout(Network.UnpSession fromSession)
        {
            try
            {
                Network.UnpMessage _cMessage = new Network.UnpMessage();
                dynamic _cActionData = new ExpandoObject();
                _cActionData.text = fromSession.DisplayName + " has logged out";
                _cMessage.AddAction(this.Name, "sysmsg", _cActionData);
                _cMessage.Broadcast();
            }
            catch (Exception exc)
            {
                Logger.Log(LogLevel.Error, this, "Logout error: {0}", exc);
                throw;
            }

        }

        public override void Dispose()
        {
            // niente da fare
        }
    }
}
