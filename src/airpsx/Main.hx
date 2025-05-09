package airpsx;

import haxe.ui.containers.Frame;
import haxe.ui.Toolkit;
import haxe.ui.components.CheckBox;
import airpsx.utils.CompileUtils;

import haxe.ui.HaxeUIApp;

class Main {

    static public function main() {

        trace("Hello, world!");

        var buildDate:Date = CompileUtils.buildDate();
        trace("Build date: " + buildDate);

        var commitHash:String = CompileUtils.buildGitCommitShaClean();
        trace("Commit hash: " + commitHash);

        var commitMessage:String = CompileUtils.buildGitCommitMessage();
        trace("Commit message: " + commitMessage);

        var systemName:String = CompileUtils.getSystemName();
        trace("System name: " + systemName);

        #if js
        Reflect.setField(js.Browser.window, "git", {
            buildDate: buildDate,
            commitHash: commitHash,
            commitMessage: commitMessage,
            systemName: systemName
        });
        #end

        Toolkit.init();

        var app = new HaxeUIApp();
        app.ready(function() {
            app.addComponent(new CheckBox());

            app.start();
        });
    }
}