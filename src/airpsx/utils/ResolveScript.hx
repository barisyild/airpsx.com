package airpsx.utils;
import airpsx.type.ScriptType;
class ResolveScript {
    public static function resolvePath(key:String, type:ScriptType) {
        return './scripts/${key}/${resolveName(key, type)}';
    }

    public static function resolveName(key:String, type:ScriptType) {
        return switch (type) {
            case ScriptType.RULESCRIPT:
                '${key}.hx';
        }
    }
}