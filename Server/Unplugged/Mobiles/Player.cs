using Alchemy.Classes;

namespace UnServer.Mobiles
{
    public class Player : MobileBase
    {
        public UserContext Context { get; set; }

        public Player()
        {
            Name = string.Empty;
        }
    }
}
