package airpsx;
import sys.db.Sqlite;
import sys.db.Connection;
import sys.FileSystem;
class GenerateDatabase {
    static public function main() {
        final databasePath:String = "./deploy/database.db";

        if(FileSystem.exists(databasePath))
            FileSystem.deleteFile(databasePath);

        var connection:Connection = Sqlite.open(databasePath);
        connection.request("CREATE TABLE scripts (key String, name String, type String, minFirmware String, maxFirmware String, version String)");

        var scriptNames:Array<String> = [for(scriptName in sys.FileSystem.readDirectory("scripts")) scriptName];
        for(scriptName in scriptNames) {
            var script:{name:String, type:String, minFirmware:String, maxFirmware:String, version:String} = haxe.Json.parse(sys.io.File.getContent('./scripts/${scriptName}/${scriptName}.json'));
            connection.request('INSERT INTO scripts (key, name, type, minFirmware, maxFirmware, version) VALUES (${quote(connection, scriptName)}, ${quote(connection, script.name)}, ${quote(connection, script.type)}, ${quote(connection, script.minFirmware)}, ${quote(connection, script.maxFirmware)}, ${quote(connection, script.version)})');
        }

        connection.close();
    }

    private static function quote(connection:Connection, value:Dynamic):String
    {
        var stringBuf:StringBuf = new StringBuf();
        connection.addValue(stringBuf, value);
        return stringBuf.toString();
    }
}
