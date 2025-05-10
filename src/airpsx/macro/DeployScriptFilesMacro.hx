package airpsx.macro;
import haxe.io.Bytes;
import airpsx.utils.ResolveScript;
import haxe.Json;
using StringTools;

class DeployScriptFilesMacro {
    public static function apply() {

        try
        {
            // Create scripts folder
            sys.FileSystem.createDirectory("deploy/scripts");

            for(fileName in sys.FileSystem.readDirectory("scripts"))
            {
                var jsonFile:Dynamic = Json.parse(sys.io.File.getContent('./scripts/${fileName}/${fileName}.json'));

                var scriptName = ResolveScript.resolveName(fileName, jsonFile.type);
                var bytes:Bytes = sys.io.File.getBytes('./scripts/${fileName}/${scriptName}');
                sys.io.File.saveBytes('deploy/scripts/${scriptName}', bytes);

                var imageBytes:Bytes = sys.io.File.getBytes('./scripts/${fileName}/${fileName}.png');
                sys.io.File.saveBytes('deploy/scripts/${fileName}.png', imageBytes);
            }
        }
        catch (e)
        {
            trace("Cannot copy scripts.", e);
            throw e;
        }
    }
}
