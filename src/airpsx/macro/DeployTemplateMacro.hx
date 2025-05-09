package airpsx.macro;

class DeployTemplateMacro {
    public static function apply() {

        try
        {
            // Create deploy folder
            sys.FileSystem.createDirectory("deploy");

            // Copy template folder to deploy folder
            copyFolderContent("template", "deploy");
        }
        catch (e)
        {
            trace("Cannot copy template to deploy folder.");
            throw e;
        }
    }

    private static function copyFolderContent(source:String, destination:String):Void
    {
        // Read source folder contents
        var sourceFolderContent:Array<String> = sys.FileSystem.readDirectory(source);

        for(sourceContent in sourceFolderContent)
        {
            var sourcePath:String = source + "/" + sourceContent;
            var destinationPath:String = destination + "/" + sourceContent;
            if(sys.FileSystem.isDirectory(sourcePath))
            {
                sys.FileSystem.createDirectory(destinationPath);
                copyFolderContent(sourcePath, destinationPath);
            }
            else
            {
                sys.io.File.copy(sourcePath, destinationPath);
            }
        }
    }
}