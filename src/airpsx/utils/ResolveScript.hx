package airpsx.utils;
import airpsx.type.ScriptType;
class ResolveScript {
    public static function resolvePath(key:String, type:ScriptType) {
        return switch (type) {
            case ScriptType.RULESCRIPT:
                './scripts/${key}/${key}.rulescript';
        }
    }
}