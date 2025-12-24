using System.Collections.Generic;
using System.Diagnostics;
using System.IO.Compression;
using System.Reflection.Emit;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

namespace DeSerializator
{
    internal class Program
    {

        //static Dictionary<string, string> UkrToUTF = new()
        //{
        //    { "А", "" }, { "Б", "" }, { "В", "" }, { "Г", "" }, { "Ґ", "" },
        //    { "Д", "" }, { "Е", "" }, { "Є", "" }, { "Ж", "" }, { "З", "" },
        //    { "И", "" }, { "І", "" }, { "Ї", "" }, { "Й", "" }, { "К", "" },
        //    { "Л", "" }, { "М", "" }, { "Н", "" }, { "О", "" }, { "П", "" },
        //    { "Р", "" }, { "С", "" }, { "Т", "" }, { "У", "" }, { "Ф", "" },
        //    { "Х", "" }, { "Ц", "" }, { "Ч", "" }, { "Ш", "" }, { "Щ", "" },
        //    { "Ь", "" }, { "Ю", "" }, { "Я", "" },
        //    { "а", "" }, { "б", "" }, { "в", "" }, { "г", "" }, { "ґ", "" },
        //    { "д", "" }, { "е", "" }, { "є", "" }, { "ж", "" }, { "з", "" },
        //    { "и", "" }, { "і", "" }, { "ї", "" }, { "й", "" }, { "к", "" },
        //    { "л", "" }, { "м", "" }, { "н", "" }, { "о", "" }, { "п", "" },
        //    { "р", "" }, { "с", "" }, { "т", "" }, { "у", "" }, { "ф", "" },
        //    { "х", "" }, { "ц", "" }, { "ч", "" }, { "ш", "" }, { "щ", "" },
        //    { "ь", "" }, { "ю", "" }, { "я", "" }
        //};


        static Dictionary<string, string> UTFToUkr = new()
        {
            { "A", "А" }, { "Ê", "Л" }, { "B", "В" }, { "è".ToUpper(), "И" }, { "é".ToUpper(), "Й" },
            { "ä".ToUpper(), "Ж" }, { "E", "Е" }, { "ý".ToUpper(), "Ю" }, { "å".ToUpper(), "З" }, { "ù".ToUpper(), "З" },
            { "ô".ToUpper(), "Ц" }, { "I", "І" }, { "ï".ToUpper(), "Ї" }, { "õ".ToUpper(), "Ч" }, { "K", "К" },
            { "ú".ToUpper(), "Л" }, { "M", "М" }, { "H", "Н" }, { "O", "О" }, { "ó".ToUpper(), "Ф" },
            { "P", "Р" }, { "C", "С" }, { "T", "Т" }, { "û".ToUpper(), "Ь" }, { "À", "Б" },
            { "X", "Х" }, { "â".ToUpper(), "Ґ" }, { "ü".ToUpper(), "Є" }, { "ö".ToUpper(), "Ш" }, { "ã".ToUpper(), "Д" },
            { "ñ".ToUpper(), "П" }, { "á".ToUpper(), "Г" }, { "ò".ToUpper(), "У" },
            { "a", "а" }, { "ê", "л" }, { "b", "в" }, { "è", "и" }, { "é", "й" },
            { "ä", "ж" }, { "e", "е" }, { "ý", "ю" }, { "å", "з" }, { "ù", "з" },
            { "ô", "ц" }, { "i", "і" }, { "ï", "ї" }, { "õ", "ч" }, { "k", "к" },
            { "ú", "л" }, { "m", "м" }, { "h", "н" }, { "o", "о" }, { "ó", "ф" },
            { "p", "р" }, { "c", "с" }, { "t", "т" }, { "û", "ь" }, { "À".ToLower(), "б" },
            { "x", "х" }, { "â", "ґ" }, { "ü", "є" }, { "ö", "ш" }, { "ã", "д" },
            { "ñ", "п" }, { "á", "г" }, { "ò", "у" }, {"þ","я" },
            {"þ".ToUpper(),"Я" }, {"Я","В" }, {"Ø", "Щ" }, {"Ø".ToLower(), "щ" }
        };

        static string localPath = ".";
        static List<string> additionalFiles = new List<string>();
        //{
        //    "streams.wav",
        //    "config.exe",
        //    "d3d8.dll",
        //    "dxwrapper.dll",

        //    "dxwrapper.ini",
        //    "eax.dll",
        //    "hitman2.exe",
        //    "Hitman2.ini",

        //    "jpegdll.dll",
        //    "Keyboard.cfg",
        //    "Msvcp60.dll",
        //    "msvcrt.dll",

        //    "p5dll.dll",
        //    "RenderD3D.dll",
        //    "RenderOpenGL.dll",
        //    "xmlparse.dll",

        //};
        static void Main(string[] args)
        {
            Console.OutputEncoding = System.Text.Encoding.UTF8;
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
          //  LocToXML();
            XmlToLoc();
            UpdateZip();
            return;
            //LocToXML();

            //var xml = File.ReadAllText("MainMenu.XML", Encoding.UTF8);
            //XmlSerializer serializer = new XmlSerializer(typeof(HitmanLOC));
            //using (StringReader reader = new StringReader(xml))
            //{
            //    HitmanLOC hitmanLOC = (HitmanLOC)serializer.Deserialize(reader);
            //    Console.WriteLine(hitmanLOC.MainPart.Name);
            //    Console.WriteLine(hitmanLOC.MainPart.Items[0].Name);
            //    Console.WriteLine(hitmanLOC.MainPart.Items[0].Value);
            //    Console.WriteLine(hitmanLOC.MainPart.Items[0].SubItems[0].Name);
            //    Console.WriteLine(hitmanLOC.MainPart.Items[0].SubItems[0].Value);
            //}
        }

        static void LocToXML()
        {
            string locDirectory = localPath + @"\loc";
            string xmlDirectory = localPath + @"\xml";
            if (!Directory.Exists(xmlDirectory))
            {
                Directory.CreateDirectory(xmlDirectory);
            }
            string[] locFiles = Directory.GetFiles(locDirectory, "*.loc");

            foreach (string locFile in locFiles)
            {
                string fileName = Path.GetFileName(locFile);
                string outputXmlFile = Path.ChangeExtension(fileName, ".XML");
                Process process = new Process()
                {
                    StartInfo = new ProcessStartInfo
                    {
                        FileName = "loctool.exe",
                        Arguments = $"x {locDirectory}\\{fileName} {xmlDirectory}\\{outputXmlFile}",
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false,
                        CreateNoWindow = true
                    }
                };

                Console.WriteLine($"Processing: {fileName} -> {outputXmlFile}");
                process.Start();

                //  process.WaitForExit();
                Task.Delay(100).GetAwaiter().GetResult();
                string output1 = process.StandardOutput.ReadToEnd();
                string error1 = process.StandardError.ReadToEnd();

                if (!string.IsNullOrEmpty(output1))
                    Console.WriteLine(output1);
                if (!string.IsNullOrEmpty(error1))
                    Console.WriteLine($"Error: {error1}");
                process.Kill();
            }
            if (!Directory.Exists(xmlDirectory + "2\\"))
            {
                Directory.CreateDirectory(xmlDirectory + "2\\");
            }

            string[] xmlFiles = Directory.GetFiles(xmlDirectory, "*.xml");
            var k = 0;
            foreach (string xmlFile in xmlFiles)
            {
                try
                {
                    var xml = File.ReadAllText(xmlFile, Encoding.UTF8);
                    XmlSerializer serializer = new XmlSerializer(typeof(HitmanLOC));
                    HitmanLOC hitmanLOC;
                    using (StringReader reader = new StringReader(xml))
                    {
                        hitmanLOC = (HitmanLOC)serializer.Deserialize(reader);
                        for (var j = 0; j < hitmanLOC.MainPart.Count; j++)
                        {
                            for (var i = 0; i < hitmanLOC.MainPart[j].Items.Count; i++)
                            {
                                GoThrouClass(hitmanLOC.MainPart[j].Items[i]);
                            }
                        }
                    }
                    var nexXml = Path.GetFileName(xmlFile);
                    using (StreamWriter writer = new StreamWriter(xmlDirectory + "2\\" + nexXml, false, Encoding.UTF8))
                    {
                        serializer.Serialize(writer, hitmanLOC);
                    }

                }catch (Exception ex)
                {
                    Console.WriteLine($"Error processing file {xmlFile}: {ex.Message}");
                }
                k++;
            }
        }

        static void UpdateZip()
        {
            string sourceFolder = localPath + @"\loc"; // Папка з .loc файлами
            string archiveFolder = localPath + @"\release-sources";  // Папка з архівами

            if (!Directory.Exists(sourceFolder) || !Directory.Exists(archiveFolder))
            {
                Console.WriteLine("Одна з директорій не існує.");
                return;
            }

            foreach (string filePath in Directory.GetFiles(archiveFolder, "*.zip", SearchOption.AllDirectories))
            {
                string fileName = Path.GetFileNameWithoutExtension(filePath);
                string archivePath = filePath, entryPath;

                if (fileName.Contains("_"))
                {
                    var parts = fileName.Split('_');
                    string level = parts[0];
                    string desc = string.Join("_", parts.Skip(1));
                    string subfolder = Path.Combine("SCENES", level);
                    //archivePath = Path.Combine(archiveFolder, "Scenes", level, $"{level}_{desc}.zip");
                    entryPath = Path.Combine(subfolder, fileName + ".LOC");
                }
                else if (filePath.Contains("AllLevels"))
                {
                    entryPath = Path.Combine("SCENES/AllLevels", fileName + ".LOC");
                }
                else if (filePath.Contains("Intro"))
                {
                    entryPath = Path.Combine("SCENES/Intro", fileName + ".LOC");
                }
                else
                {
                    // archivePath = Path.Combine(archiveFolder, "Scenes", $"{fileName}.zip");
                    entryPath = Path.Combine("SCENES", fileName + ".LOC");
                }

                entryPath = entryPath.Replace("\\", "/");

                if (!File.Exists(archivePath))
                {
                    continue;
                }

                using (var archive = ZipFile.Open(archivePath, ZipArchiveMode.Update))
                {
                    var existingEntry = archive.GetEntry(entryPath);
                    if (existingEntry != null)
                    {
                        existingEntry?.Delete();

                        var sourceFile = Path.Combine(sourceFolder, fileName + ".loc");
                        sourceFile = File.Exists(sourceFile) ? sourceFile : Path.Combine(sourceFolder, "main.loc");
                        archive.CreateEntryFromFile(sourceFile, entryPath, CompressionLevel.Optimal);
                    }
                }

                Console.WriteLine($"Файл {entryPath} додано до архіву {archivePath}");
            }

            if (File.Exists("Hitman_SA_Ukr.zip"))
            {
                File.Delete("Hitman_SA_Ukr.zip");
            }

            using (FileStream zipToCreate = new FileStream("Hitman_SA_Ukr.zip", FileMode.Create))
            using (ZipArchive archive = new ZipArchive(zipToCreate, ZipArchiveMode.Create))
            {
                var scenesFolder = archiveFolder + "\\Scenes";
                string rootFolderName = Path.GetFileName(scenesFolder.TrimEnd(Path.DirectorySeparatorChar));

                // Додаємо всі файли з папки до архіву разом із папкою
                foreach (string file in Directory.GetFiles(scenesFolder, "*", SearchOption.AllDirectories))
                {
                    Console.WriteLine($"Processing - {file}");
                    string relativePath = Path.GetRelativePath(scenesFolder, file);
                    string entryScene = Path.Combine(rootFolderName, relativePath).Replace("\\", "/"); // Відносний шлях у архіві
                    archive.CreateEntryFromFile(file, entryScene);
                }

                foreach (var additionalFileName in additionalFiles)
                {
                    string additionalFile = archiveFolder + "\\" + additionalFileName;
                    archive.CreateEntryFromFile(additionalFile, additionalFileName);
                }

            }

            Console.WriteLine("Архів успішно створено!");
        }

        static void XmlToLoc()
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
            string xmlDirectory = localPath + @"\xml";
            string newXmplDirectory = localPath + @"\xml2";
            string locDirectory = localPath + @"\loc";
            if (!Directory.Exists(locDirectory))
            {
                Directory.CreateDirectory(locDirectory);
            }
            if (!Directory.Exists(newXmplDirectory))
            {
                Directory.CreateDirectory(newXmplDirectory);
            }


            string[] xmlFiles = Directory.GetFiles(xmlDirectory, "*.xml");
            var mainXmlFile = xmlFiles.FirstOrDefault(x => string.Equals(Path.GetFileName(x), "main.xml", StringComparison.InvariantCultureIgnoreCase));
            var mainXml = File.ReadAllText(mainXmlFile, Encoding.UTF8);
            XmlSerializer mainSerializer = new XmlSerializer(typeof(HitmanLOC));
            HitmanLOC mainHitmanLOC;
            using (StringReader reader = new StringReader(mainXml))
            {
                mainHitmanLOC = (HitmanLOC)mainSerializer.Deserialize(reader);
                for (var i = 0; i < mainHitmanLOC.MainPart[0].Items.Count; i++)
                {
                    GoThrouClassToUTF(mainHitmanLOC.MainPart[0].Items[i]);
                }
            }

            foreach (string xmlFile in xmlFiles)
            {
                var xml = File.ReadAllText(xmlFile, Encoding.UTF8);
                XmlSerializer serializer = new XmlSerializer(typeof(HitmanLOC));
                HitmanLOC hitmanLOC;
                using (StringReader reader = new StringReader(xml))
                {
                    hitmanLOC = (HitmanLOC)serializer.Deserialize(reader);

                    hitmanLOC.MainPart[0] = mainHitmanLOC.MainPart[0];
                    for (var j = 1; j < hitmanLOC.MainPart.Count; j++)
                    {
                        for (var i = 0; i < hitmanLOC.MainPart[j].Items.Count; i++)
                        {
                            GoThrouClassToUTF(hitmanLOC.MainPart[j].Items[i]);
                        }
                    }
                }

                using (StreamWriter writer = new StreamWriter(xmlFile, false, Encoding.UTF8))
                {
                    serializer.Serialize(writer, hitmanLOC);
                }

                string fileName = Path.GetFileName(xmlFile);
                string[] lines = File.ReadAllLines(xmlFile, Encoding.UTF8);
                if (lines.Length > 0)
                {
                    lines[0] = "<?xml version=\"1.0\" encoding=\"windows-1251\" standalone=\"no\"?>";
                    File.WriteAllLines($"{newXmplDirectory}\\{fileName}", lines, Encoding.UTF8);
                }

                string outputLocFile = Path.ChangeExtension(fileName, ".loc");

                Process process = new Process()
                {
                    StartInfo = new ProcessStartInfo
                    {
                        FileName = "loctool.exe",
                        Arguments = $"c {newXmplDirectory}\\{fileName} {locDirectory}\\{outputLocFile}",
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false,
                        CreateNoWindow = true
                    }
                };

                Console.WriteLine($"Processing: {xmlFile} -> {outputLocFile}");
                process.Start();

                //  process.WaitForExit();
                Task.Delay(1000).GetAwaiter().GetResult();
                string output1 = process.StandardOutput.ReadToEnd();
                string error1 = process.StandardError.ReadToEnd();

                if (!string.IsNullOrEmpty(output1))
                    Console.WriteLine(output1);
                if (!string.IsNullOrEmpty(error1))
                    Console.WriteLine($"Error: {error1}");
                process.Kill();
            }

        }

        private static void GoThrouClassToUTF(Item root)
        {
            if (root == null) return;
            Stack<Item> stack = new Stack<Item>();
            stack.Push(root);

            while (stack.Count > 0)
            {
                Item current = stack.Pop();
                if (!string.IsNullOrEmpty(current.Value))
                {

                    foreach (var ukrpair in UTFToUkr)
                    {
                        current.Value = current.Value.Replace(ukrpair.Value, ukrpair.Key);//TranslateText(current.value, current.name);
                    }

                    // Console.WriteLine(current.Value);
                }

                if (current.SubItems != null)
                {
                    for (int i = current.SubItems.Count - 1; i >= 0; i--)
                    {
                        if (current.SubItems[i] != null) // Переконуємося, що елемент не null
                        {
                            stack.Push(current.SubItems[i]);
                        }
                    }
                }
            }
        }

        private static void GoThrouClass(Item root)
        {
            if (root == null) return;
            Stack<Item> stack = new Stack<Item>();
            stack.Push(root);

            while (stack.Count > 0)
            {
                Item current = stack.Pop();
                if (!string.IsNullOrEmpty(current.Value))
                {

                    foreach (var ukrpair in UTFToUkr)
                    {
                        current.Value = current.Value.Replace(ukrpair.Key, ukrpair.Value);//TranslateText(current.value, current.name);
                    }

                    //  Console.WriteLine(current.Value);
                }

                if (current.SubItems != null)
                {
                    for (int i = current.SubItems.Count - 1; i >= 0; i--)
                    {
                        if (current.SubItems[i] != null) // Переконуємося, що елемент не null
                        {
                            stack.Push(current.SubItems[i]);
                        }
                    }
                }
            }
        }
    }
}
