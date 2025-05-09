package airpsx.utils;
import haxe.io.Bytes;
import haxe.macro.Expr.ExprOf;
using StringTools;
using tools.MacroExpressionTools;

class CompileUtils {
    macro public static function getSystemName():ExprOf<String> {
        return Sys.systemName().toExpr();
    }

    /** Returns a string of the current git sha1 */
    macro public static function buildGitCommitShaClean():ExprOf<String> {
        var proc = new sys.io.Process('git', ['log', "--pretty=format:%h", '-n', '1']);
        return @:privateAccess proc.stdout.readLine().toExpr();
    }

    macro public static function buildGitCommitMessage():ExprOf<String>
    {
        var proc = new sys.io.Process('git', ['log', "--pretty=%B", '-n', '1']);
        var commitMessageBytes:Bytes = proc.stdout.readAll();
        var commitMessage:String = commitMessageBytes.toString().trim();
        return @:privateAccess commitMessage.toExpr();
    }

    macro public static function buildDate():ExprOf<Date> {
        var date = Date.now();
        var year = date.getFullYear().toExpr();
        var month = date.getMonth().toExpr();
        var day = date.getDate().toExpr();
        var hours = date.getHours().toExpr();
        var mins = date.getMinutes().toExpr();
        var secs = date.getSeconds().toExpr();
        return macro new Date($year, $month, $day, $hours, $mins, $secs);
    }
}