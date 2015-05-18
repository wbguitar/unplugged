namespace UnServer.Mobiles
{
    public class MobileBase
    {
        public string Name { get; set; }

        protected virtual void Initialize() { }
        private void OnInitialize()
        {
            Name = "Non Assegnato";
            Initialize();
        }

        public MobileBase()
        {
            OnInitialize();
        }
    }
}
