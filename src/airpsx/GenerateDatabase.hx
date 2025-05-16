package airpsx;
import sys.db.Sqlite;
import sys.db.Connection;
import sys.FileSystem;
import airpsx.type.ConsoleType;
import airpsx.macro.tools.AbstractEnumTools;
import haxe.io.Error;
import sys.io.File;
import airpsx.type.ScriptType;
import airpsx.utils.ResolveScript;
import haxe.crypto.Md5;
import haxe.io.Bytes;
import com.hurlant.crypto.symmetric.AESKey;
import com.hurlant.crypto.rsa.RSAKey;
import com.hurlant.math.BigInteger;
import com.hurlant.util.ByteArray;
import com.hurlant.util.der.PEM;
import airpsx.macro.EnvironmentMacro;
class GenerateDatabase {
    static public function main() {
        var dateReg = new EReg("^\\d{2}\\.\\d{2}$", "");

        var consoleTypes:Array<String> = AbstractEnumTools.getValues(ConsoleType);
        var scriptTypes:Array<String> = AbstractEnumTools.getValues(ScriptType);
        var scriptNames:Array<String> = [for(scriptName in sys.FileSystem.readDirectory("scripts")) scriptName];

        FileSystem.createDirectory('./deploy/db/');

        for(consoleType in consoleTypes) {
            final databasePath:String = './deploy/db/${consoleType}.db';

            // Clear old database
            if(FileSystem.exists(databasePath)) {
                FileSystem.deleteFile(databasePath);
            }

            var connection:Connection = Sqlite.open(databasePath);
            connection.request("CREATE TABLE scripts (key Text, name Text, scriptHash Text, imageHash Text, type Text, minFirmware Text, maxFirmware Text, version Text, authorName Text, authorSrc Text)");

            for(scriptName in scriptNames) {
                var script:ScriptTypedef = haxe.Json.parse(sys.io.File.getContent('./scripts/${scriptName}/${scriptName}.json'));
                if(!script.enabled)
                    continue;

                var platforms:Array<ScriptPlatformTypedef> = script.platforms;
                if(platforms.length == 0) {
                    throw 'No platforms found in ${scriptName}';
                }

                var illegalPlatform:ScriptPlatformTypedef = Lambda.find(platforms, (platform) -> !consoleTypes.contains(platform.console));
                if(illegalPlatform != null) {
                    throw 'Unknown console type ${illegalPlatform.console} in ${scriptName}';
                }

                var scriptType:ScriptType = Lambda.find(scriptTypes, (type) -> type == script.type);
                if(scriptType == null) {
                    throw 'Unknown script type ${script.type} in ${scriptName}';
                }

                var scriptPath:String = ResolveScript.resolvePath(scriptName, scriptType);
                var scriptBytes:Bytes = File.getBytes(scriptPath);
                var scriptHash:String = Md5.make(scriptBytes).toHex();

                var imageBytes:Bytes = sys.io.File.getBytes('./scripts/${scriptName}/${scriptName}.png');
                var imageHash:String = Md5.make(imageBytes).toHex();

                validateAirPSXVersion(script.version);

                var platform:ScriptPlatformTypedef = Lambda.find(platforms, (platform) -> platform.console == consoleType);
                if(platform != null) {
                    validateVersionFormat(platform.minFirmware);
                    validateVersionFormat(platform.maxFirmware);

                    connection.request('INSERT INTO scripts (key, name, scriptHash, imageHash, type, minFirmware, maxFirmware, version, authorName, authorSrc) VALUES (${quote(connection, scriptName)}, ${quote(connection, script.name)}, ${quote(connection, scriptHash)}, ${quote(connection, imageHash)}, ${quote(connection, scriptType)}, ${quote(connection, platform.minFirmware)}, ${quote(connection, platform.maxFirmware)}, ${quote(connection, script.version)}, ${quote(connection, script.author.name)}, ${quote(connection, script.author.src)})');
                }
            }

            connection.close();

            var databaseBytes:ByteArray = ByteArray.fromBytes(File.getBytes(databasePath));

            var privateKey = PEM.readRSAPrivateKey(EnvironmentMacro.get("PRIVATE_KEY", ""));
            if(privateKey == null) {
                trace("Failed to read private key, skip signing.");
            }else{
                var signedBytes:ByteArray = new ByteArray();
                privateKey.sign(databaseBytes, signedBytes, databaseBytes.length);

                File.saveBytes('${databasePath}.signed', signedBytes);
            }
        }
    }

    private static function quote(connection:Connection, value:Dynamic):String
    {
        var stringBuf:StringBuf = new StringBuf();
        connection.addValue(stringBuf, value);
        return stringBuf.toString();
    }

    private static function validateAirPSXVersion(version:String):Void {
        var versionRegex:EReg = new EReg("^\\d+\\.\\d{2}$", "");

        if(!versionRegex.match(version)) {
            throw 'Invalid AirPSX version format: ${version}';
        }
    }

    private static function validateVersionFormat(version:String):Void {
        var versionRegex:EReg = new EReg("^\\d{2}\\.\\d{2}$", "");

        if(!versionRegex.match(version)) {
            throw 'Invalid version format: ${version}';
        }
    }
}


typedef ScriptTypedef = {
    name:String,
    enabled: Bool,
    type:ScriptType,
    version:String,
    author:AuthorTypedef,
    platforms:Array<ScriptPlatformTypedef>
};

typedef ScriptPlatformTypedef = {
    console:ConsoleType,
    minFirmware:String,
    maxFirmware:String
};

typedef AuthorTypedef = {
    name:String,
    src:String
};