using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Dynamic;
using System.Collections;
using System.Collections.Concurrent;
using System.Threading;

namespace UnServer
{
    using Network.Log;

    class UnpMoveItData
    {
        public int X = 0;
        public int Y = 0;
    }

    class UnpMoveIt : Network.UnpModule
    {
        private dynamic _baseActionData;

        // modulo di test con movimento in tempo reale
        public UnpMoveIt(): base ("unpmoveit")
        {

            _baseActionData = new ExpandoObject();
            _baseActionData.baseaccel = 700;
            _baseActionData.maxspeed = 300;
            _baseActionData.brakepower = 5;
            _baseActionData.firelifespan = 500;
            _baseActionData.boomlifespan = 3000;
            _baseActionData.firespeed = 400;
            _baseActionData.firestartdist = 20;
            _baseActionData.circleradius = 12;
            _baseActionData.fireradius = 3;
            _baseActionData.boomsize = 16;

			_StartSimulation();
        }

        // dictionary per i dati del modulo in base alla sessione
        private ConcurrentDictionary<Network.UnpSession, UnpMoveItData> _moveItDataDictionary = new ConcurrentDictionary<Network.UnpSession, UnpMoveItData>();

        // tipi degli oggetti da simulare
        class MIPlayer
        {
            public float x = 0;
            public float y = 0;
            public int goToX = 0;
            public int goToY = 0;
            public float speedX = 0;
            public float speedY = 0;
            public DateTime lastUpdate = new DateTime();

            public float HP
            {
                get { return _HP; }
                set { }
            }

            private float _HP = 100;

            public void DoDamage(float damageDone)
            {
                if (!IsDead)
                {
                    _HP -= damageDone;
                    if (_HP <= 0)
                    {
                        _HP = 0;
                        IsDead = true;
                    }

                    _CheckHPChange();
                }
            }

            public void DoHeal(float healDone)
            {
                if (IsDead) healDone *= 5;

                _HP += healDone;

                if (_HP > 100)
                {
                    IsDead = false;
                    _HP = 100;
                }

                _CheckHPChange();
            }

            private DateTime _LastHPUpdateTime = new DateTime();
            private float _LastHPUpdateValue = 100;

            private int _MinHPMSecForUpdate = 200;
            private int _MinHPChangeForUpdate = 5;

            public bool IsDead = false;
            private bool _LastDeadUpdate = false;

            private void _CheckHPChange()
            {
                bool _timeHasPassed = (DateTime.Now - _LastHPUpdateTime).TotalMilliseconds > _MinHPMSecForUpdate;
                bool _significantChange = Math.Abs(_HP - _LastHPUpdateValue) > _MinHPChangeForUpdate;
                bool _deadChange = (IsDead != _LastDeadUpdate);

                if ((_timeHasPassed && _significantChange) || _deadChange)
                {
                    ShouldSendHPData = true;
                }
            }

            public bool ShouldSendHPData = false;

            public void ResetHPUpdate()
            {
                ShouldSendHPData = false;
                _LastHPUpdateValue = _HP;
                _LastDeadUpdate = IsDead;
                _LastHPUpdateTime = DateTime.Now;
            }

            public MIPlayer()
            {
                lastUpdate = DateTime.Now;
                _LastHPUpdateTime = DateTime.Now;
            }
        }

        class MIFire
        {
            public float fireX = 0;
            public float fireY = 0;
            public int fireToX = 0;
            public int fireToY = 0;
            public float fireSpeedX = 0;
            public float fireSpeedY = 0;
            public DateTime creationTime = new DateTime();
            public DateTime lastUpdate = new DateTime();
            public MIPlayer firedFrom = null;
        }

        class MIBoom
        {
            public int boomX = 0;
            public int boomY = 0;
            public DateTime creationTime = new DateTime();
            public DateTime lastUpdate = new DateTime();
        }

        // vari array per gli oggetti da simulare
        private ConcurrentDictionary<Network.UnpSession, MIPlayer> _cPlayersDict = new ConcurrentDictionary<Network.UnpSession, MIPlayer>();
        private ConcurrentDictionary<MIFire, string> _cFiresBag = new ConcurrentDictionary<MIFire, string>();
        private ConcurrentDictionary<MIBoom, string> _cBoomsBag = new ConcurrentDictionary<MIBoom, string>();

        public override void HandleAction(string actionName, dynamic actionData, Network.UnpSession fromSession)
        {
            DateTime _nowTime = DateTime.Now;

            switch (actionName)
            {
                case "move":
                    {
                        try
                        {
                            if (!_cPlayersDict[fromSession].IsDead)
                            {
                                UnpMoveItData _cMIData = _moveItDataDictionary[fromSession];

                                // l'utente si sposta
                                _cMIData.X = Convert.ToInt32(actionData.x.Value);
                                _cMIData.Y = Convert.ToInt32(actionData.y.Value);

                                // aggiorno il goto nella simulazione
                                _cPlayersDict[fromSession].goToX = _cMIData.X;
                                _cPlayersDict[fromSession].goToY = _cMIData.Y;

                                // mando a tutti la sua nuova posizione
                                Network.UnpMessage _cMessage = new Network.UnpMessage();

                                dynamic _cActionData = new ExpandoObject();
                                _cActionData.id = fromSession.SessionId;
                                _cActionData.x = _cMIData.X;
                                _cActionData.y = _cMIData.Y;
                                _cMessage.AddAction(this.Name, "move", _cActionData);

                                _cMessage.Broadcast();
                            }
                        }
                        catch (Exception exc)
                        {
                            Logger.Log(LogLevel.Error, this, "Move error: {0}", exc.ToString());
                            throw;
                        }
                    }
                    break;
                case "fire":
                    {
                        try
                        {
                            if (!_cPlayersDict[fromSession].IsDead)
                            {
                                UnpMoveItData _cMIData = _moveItDataDictionary[fromSession];

                                // l'utente spara D:
                                int _fireToX = Convert.ToInt32(actionData.x.Value);
                                int _fireToY = Convert.ToInt32(actionData.y.Value);

                                // aggiungo lo sparo alla simulazione

                                MIFire _fData = new MIFire();

                                _fData.fireX = _cMIData.X;
                                _fData.fireY = _cMIData.Y;
                                _fData.fireToX = Convert.ToInt32(actionData.x.Value);
                                _fData.fireToY = Convert.ToInt32(actionData.y.Value);
                                _fData.creationTime = _nowTime;
                                _fData.lastUpdate = _nowTime;
                                _fData.firedFrom = _cPlayersDict[fromSession];

                                float _diffX = -(_fData.fireX - _fData.fireToX);
                                float _diffY = -(_fData.fireY - _fData.fireToY);

                                float _diffModule = (float)Math.Sqrt(Math.Pow(_diffX, 2) + Math.Pow(_diffY, 2));

                                int _fireSpeed = _baseActionData.firespeed;
                                int _fireStartDist = _baseActionData.firestartdist;

                                _fData.fireSpeedX = _fireSpeed * _diffX / _diffModule;
                                _fData.fireSpeedY = _fireSpeed * _diffY / _diffModule;

                                _fData.fireX += _fireStartDist * _diffX / _diffModule;
                                _fData.fireY += _fireStartDist * _diffY / _diffModule;

                                _cFiresBag.TryAdd(_fData, string.Empty);

                                // mando a tutti il punto in cui ha fatto fuoco
                                Network.UnpMessage _cMessage = new Network.UnpMessage();

                                dynamic _cActionData = new ExpandoObject();
                                _cActionData.id = fromSession.SessionId;
                                _cActionData.x = _fireToX;
                                _cActionData.y = _fireToY;
                                _cMessage.AddAction(this.Name, "fire", _cActionData);

                                _cMessage.Broadcast();
                            }
                        }
                        catch (Exception exc)
                        {
                            Logger.Log(LogLevel.Error, this, "Fire error: {0}", exc.ToString());
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
                // aggiungo i dati iniziali relativi all'utente che ha loggato
                UnpMoveItData _startingPos = new UnpMoveItData();
                _startingPos.X = (int)Math.Round(UnpUtils.GetRandomDouble() * 200) - 100;
                _startingPos.Y = (int)Math.Round(UnpUtils.GetRandomDouble() * 200) - 100;

                _moveItDataDictionary.TryAdd(fromSession, _startingPos);

                MIPlayer _cPlayer = new MIPlayer();
                _cPlayer.x = _startingPos.X;
                _cPlayer.y = _startingPos.Y;
                _cPlayer.goToX = _startingPos.X;
                _cPlayer.goToY = _startingPos.Y;
                _cPlayer.lastUpdate = DateTime.Now;
                _cPlayersDict.TryAdd(fromSession, _cPlayer);

                Network.UnpMessage _cMessage = new Network.UnpMessage();

                // mando le costanti base da usare per la simulazione

                _cMessage.AddAction(this.Name, "init", _baseActionData);

                // mando i dati di di tutti all'utente che ha loggato
                foreach (Network.UnpSession _cSession in _moveItDataDictionary.Keys)
                {
                    if (_cSession != fromSession)
                    {
                        dynamic _cActionData = new ExpandoObject();
                        _cActionData.id = _cSession.SessionId;
                        _cActionData.name = _cSession.DisplayName;
                        _cActionData.color = _cSession.Color;
                        _cActionData.x = _moveItDataDictionary[_cSession].X.ToString();
                        _cActionData.y = _moveItDataDictionary[_cSession].Y.ToString();
                        _cActionData.hp = _cPlayersDict[_cSession].HP.ToString();
                        _cActionData.dead = _cPlayersDict[_cSession].IsDead.ToString();
                        _cMessage.AddAction(this.Name, "add", _cActionData);
                    }
                }

                _cMessage.Send(fromSession.SessionId);

                // mando i dati dell'utente che ha loggato a tutti
                _cMessage = new Network.UnpMessage();

                dynamic _thisActionData = new ExpandoObject();
                _thisActionData.id = fromSession.SessionId;
                _thisActionData.name = fromSession.DisplayName;
                _thisActionData.color = fromSession.Color;
                _thisActionData.x = _moveItDataDictionary[fromSession].X.ToString();
                _thisActionData.y = _moveItDataDictionary[fromSession].Y.ToString();
                _thisActionData.hp = _cPlayersDict[fromSession].HP.ToString();
                _thisActionData.dead = _cPlayersDict[fromSession].IsDead.ToString();
                _cMessage.AddAction(this.Name, "add", _thisActionData);

                _cMessage.Broadcast();
            }
            catch (Exception exc)
            {
                Logger.Log(LogLevel.Error, this, "Login error: {0}", exc.ToString());
                throw;
            }
        }

        public override void HandleLogout(Network.UnpSession fromSession)
        {
            try
            {
                // dico a tutti di rimuovere l'utente che ha sloggato
            Network.UnpMessage _cMessage = new Network.UnpMessage();

            dynamic _thisActionData = new ExpandoObject();
            _thisActionData.id = fromSession.SessionId;
            _cMessage.AddAction(this.Name, "del", _thisActionData);

            _cMessage.Broadcast();

            // rimuovo i dati relativi all'utente che ha sloggato
            UnpMoveItData _moveItData;
            _moveItDataDictionary.TryRemove(fromSession, out _moveItData);

            MIPlayer _outPlayer;
            _cPlayersDict.TryRemove(fromSession, out _outPlayer);

            }
            catch (Exception exc)
            {
                Logger.Log(LogLevel.Error, this, "Logout error: {0}", exc.ToString());
                throw;
            }
        }

        Thread simulationThread;

        private void _StartSimulation()
        {
            simulationThread = new Thread(new ThreadStart(this._SimulationLoop));
            simulationThread.Start();
        }

        private void _SimulationLoop()
        {
            int _threadSleep = 30;
            DateTime _lastCollisionCheck = DateTime.Now;

            while (true)
            {
                Thread.Sleep(_threadSleep);

                DateTime _nowTime = DateTime.Now;

                int _baseAccel = _baseActionData.baseaccel;
                int _maxSpeed = _baseActionData.maxspeed = 300;
                int _brakePower = _baseActionData.brakepower = 5;
                int _fireLifeSpan = _baseActionData.firelifespan = 500;
                int _boomLifeSpan = _baseActionData.boomlifespan = 3000;

                // update

                ArrayList _fireToRemove = new ArrayList();

                foreach (MIFire _fData in _cFiresBag.Keys)
			    {
				    if((_nowTime - _fData.creationTime).TotalMilliseconds > _fireLifeSpan)
				    {
					    _fireToRemove.Add(_fData);
				    }
				    else
				    {
					    var _updateTimeDiff = (_nowTime - _fData.lastUpdate).TotalMilliseconds / 1000;
					
					    _fData.fireX += (float)(_fData.fireSpeedX * _updateTimeDiff);
                        _fData.fireY += (float)(_fData.fireSpeedY * _updateTimeDiff);

                        _fData.lastUpdate = _nowTime;
				    }
			    }

                foreach (MIFire _cRemoveObject in _fireToRemove)
                {
                    MIBoom _bData = new MIBoom();

                    _bData.boomX = (int)Math.Round(_cRemoveObject.fireX);
                    _bData.boomY = (int)Math.Round(_cRemoveObject.fireY);
                    _bData.creationTime = _nowTime;

                    _cBoomsBag.TryAdd(_bData, string.Empty);
				
                    string _outFire;

                    _cFiresBag.TryRemove(_cRemoveObject, out _outFire);
			    }

                ArrayList _boomToRemove = new ArrayList();

                foreach (MIBoom _bData in _cBoomsBag.Keys)
                {
				    if((_nowTime - _bData.creationTime).TotalMilliseconds > _boomLifeSpan)
				    {
					    _boomToRemove.Add(_bData);
				    }
			    }

                foreach (MIBoom _cRemoveObject in _boomToRemove)
                {
                    string _outBoom;

                    _cBoomsBag.TryRemove(_cRemoveObject, out _outBoom);
                }

                foreach (Network.UnpSession _cSession in _cPlayersDict.Keys)
                {
                    MIPlayer _cData = _cPlayersDict[_cSession];

                    float _updateTimeDiff = (float)((_nowTime - _cData.lastUpdate).TotalMilliseconds / 1000);

                    float _diffX = -(_cData.x - _cData.goToX);
                    float _diffY = -(_cData.y - _cData.goToY);

                    if (Math.Abs(_diffX) < 0.5 && Math.Abs(_diffY) < 0.5)
                    {
                        _diffY = 0;
                        _cData.y = _cData.goToY;
                        _cData.speedY = 0;
                        _diffX = 0;
                        _cData.x = _cData.goToX;
                        _cData.speedX = 0;
                    }

                    float _diffModule = (float)Math.Sqrt(Math.Pow(_diffX, 2) + Math.Pow(_diffY, 2));

                    if (_diffX != 0)
                    {
                        var _diffXRatio = _diffX / _diffModule;
                        var _accelX = _baseAccel * _diffXRatio;

                        if (Math.Abs(_cData.speedX) / _brakePower > Math.Abs(_diffX))
                        {
                            _accelX = -_cData.speedX * _brakePower;
                        }

                        _cData.speedX += (_accelX * _updateTimeDiff);
                    }

                    if (_diffY != 0)
                    {
                        var _diffYRatio = _diffY / _diffModule;
                        var _accelY = _baseAccel * _diffYRatio;

                        if (Math.Abs(_cData.speedY) / _brakePower > Math.Abs(_diffY))
                        {
                            _accelY = -_cData.speedY * _brakePower;
                        }

                        _cData.speedY += (_accelY * _updateTimeDiff);
                    }

                    var _speedModule = Math.Sqrt(Math.Pow(_cData.speedX, 2) + Math.Pow(_cData.speedY, 2));

                    if (_speedModule > _maxSpeed)
                    {
                        _cData.speedX = (float)(_maxSpeed * _cData.speedX / _speedModule);
                        _cData.speedY = (float)(_maxSpeed * _cData.speedY / _speedModule);
                    }

                    _cData.x += (_cData.speedX * _updateTimeDiff);
                    _cData.y += (_cData.speedY * _updateTimeDiff);

                    _cData.lastUpdate = _nowTime;
                }

                int _circleRadus = _baseActionData.circleradius;
                int _fireRadius = _baseActionData.fireradius;
                int _boomSize = _baseActionData.boomsize;

                int _fireDPS = 350;
                int _boomDPS = 20;

                //controllo collisioni fuoco - player
                foreach (Network.UnpSession _cSession in _cPlayersDict.Keys)
                {
                    MIPlayer _cDataP = _cPlayersDict[_cSession];

                    foreach (MIFire _cDataF in _cFiresBag.Keys)
                    {
                        if (_cDataF.firedFrom != _cDataP)
                        {
                            float _cDist = (float)Math.Sqrt(Math.Pow(_cDataP.x - _cDataF.fireX, 2) + Math.Pow(_cDataP.y - _cDataF.fireY, 2));

                            if (_cDist < _circleRadus + _fireRadius)
                            {
                                float _cDamage = (float)(_fireDPS * (_nowTime - _lastCollisionCheck).TotalMilliseconds / 1000);
                                _cDataP.DoDamage(_cDamage);
                            }
                        }
                    }
                }

                //controllo collisioni esplosioni - player
                foreach (Network.UnpSession _cSession in _cPlayersDict.Keys)
                {
                    MIPlayer _cDataP = _cPlayersDict[_cSession];

                    foreach (MIBoom _cDataB in _cBoomsBag.Keys)
                    {
                        float _cDist = (float)Math.Sqrt(Math.Pow(_cDataP.x - _cDataB.boomX, 2) + Math.Pow(_cDataP.y - _cDataB.boomY, 2));

                        if (_cDist < _circleRadus + _boomSize)
                        {
                            float _cDamage = (float)(_boomDPS * (_nowTime - _lastCollisionCheck).TotalMilliseconds / 1000);
                            _cDataP.DoDamage(_cDamage);
                        }
                    }
                }

                float _regenHPS = 3;
                //faccio rigenerare hp a tutti
                foreach (Network.UnpSession _cSession in _cPlayersDict.Keys)
                {
                    MIPlayer _cDataP = _cPlayersDict[_cSession];

                    float _cHeal = (float)(_regenHPS * (_nowTime - _lastCollisionCheck).TotalMilliseconds / 1000);
                    _cDataP.DoHeal(_cHeal);
                }

                _lastCollisionCheck = _nowTime;

                // controllo aggiornamenti HP da mandare
                Network.UnpMessage _cMessage = new Network.UnpMessage();

                bool _somethingAdded = false;

                foreach (Network.UnpSession _cSession in _cPlayersDict.Keys)
                {
                    MIPlayer _cDataP = _cPlayersDict[_cSession];

                    if (_cDataP.ShouldSendHPData)
                    {
                        dynamic _cActionData = new ExpandoObject();
                        _cActionData.id = _cSession.SessionId;
                        _cActionData.hp = _cDataP.HP.ToString();
                        _cActionData.dead = _cDataP.IsDead.ToString();
                        _cMessage.AddAction(this.Name, "sethp", _cActionData);

                        _cDataP.ResetHPUpdate();

                        _somethingAdded = true;
                    }
                }

                if (_somethingAdded)
                {
                    _cMessage.Broadcast();
                }
            }
        }

        public override void Dispose()
        {
            if (simulationThread != null && simulationThread.IsAlive)
            {
                simulationThread.Abort();
                simulationThread.Join();
            }
        }
    }
}
