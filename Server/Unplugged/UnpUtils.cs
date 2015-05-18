using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace UnServer
{
    static class UnpUtils
    {
        static private Random _Random = new Random();

        public static string GetRandomCssColor()
        {
            return "#" + GetRandomHex(6);
        }

        public static string GetRandomHex()
        {
            return GetRandomHex(1);
        }

        public static string GetRandomHex(int length)
        {
            string _retVal = string.Empty;

            for (int i = 0; i < length; i++)
            {
                int _cNum = (int)Math.Floor(_Random.NextDouble() * 16);
                string _cChar = null;

                if (_cNum < 10)
                {
                    _cChar = _cNum.ToString();
                }
                else
                {
                    switch (_cNum)
                    {
                        case 10:
                            _cChar += 'a';
                            break;
                        case 11:
                            _cChar += 'b';
                            break;
                        case 12:
                            _cChar += 'c';
                            break;
                        case 13:
                            _cChar += 'd';
                            break;
                        case 14:
                            _cChar += 'e';
                            break;
                        case 15:
                            _cChar += 'f';
                            break;
                    }
                }

                _retVal += _cChar;
            }

            return _retVal;
        }

        public static double GetRandomDouble()
        {
            return _Random.NextDouble();
        }
    }
}
