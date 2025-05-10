package airpsx.macro.tools;
#if macro
import haxe.macro.Context;
#end

class MacroExpressionTools {
    #if macro
    public static function toExpr(v:Dynamic) {
        return Context.makeExpr(v, Context.currentPos());
    }
    #end
}