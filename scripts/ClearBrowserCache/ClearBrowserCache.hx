import airpsx.utils.FileUtils;
import sys.FileSystem;

function main() {
    var paths:Array<String> = [];
    var profileIds:Array<String> = FileSystem.readDirectory('/user/home');

    for(profileId in profileIds)
    {
        for(filePath in FileUtils.getRecursiveFiles(['/user/home/${profileId}/webkit/shell/']))
        {
            if(FileSystem.isDirectory(filePath) || !FileSystem.exists(filePath))
                continue;
            paths.push(filePath);
        }
    }

    for(path in paths)
    {
        FileSystem.deleteFile(path);
    }

    var deletedFileCount:Int = paths.length;
    if(deletedFileCount == 0) {
        sceKernelSendNotificationRequest('Browser cache is already empty.');
        return 'Browser cache is already empty.';
    }else{
        sceKernelSendNotificationRequest('Browser cache cleared successfully.');
        return 'The following ${paths.length} files were successfully deleted; \n${paths.join("\n")}';
    }
}();