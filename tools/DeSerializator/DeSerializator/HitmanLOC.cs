using System.Xml.Serialization;

namespace DeSerializator
{

    [XmlRoot("HitmanLOC")]
    public class HitmanLOC
    {
        [XmlElement("MainPart")]
        public List<MainPart> MainPart { get; set; }
    }

    public class MainPart
    {
        [XmlAttribute("name")]
        public string Name { get; set; }

        [XmlElement("Item")]
        public List<Item> Items { get; set; }
    }

    public class Item
    {
        [XmlAttribute("name")]
        public string Name { get; set; }

        [XmlElement("Item")]
        public List<Item> SubItems { get; set; }

        [XmlText]
        public string Value { get; set; }
    }

}
