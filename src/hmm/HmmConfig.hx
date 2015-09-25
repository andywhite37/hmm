package hmm;

import haxe.Json;
import haxe.io.Path;
import hmm.utils.Shell;
import sys.FileSystem;
import sys.io.File;

typedef HmmConfigFile = {
  dependencies: Array<LibraryConfig>
};

class HmmConfig {
  public static var HMM_JSON_FILE_NAME = "hmm.json";
  public static var HAXELIB_REPO_DIR_NAME = ".haxelib";

  public static function getHmmJsonPath() {
    return Path.join([Shell.workingDirectory, HMM_JSON_FILE_NAME]);
  }

  public static function getLocalHaxelibRepoPath() {
    return Path.join([Shell.workingDirectory, HAXELIB_REPO_DIR_NAME]);
  }

  public static function hasHmmJson(){
    return FileSystem.exists(getHmmJsonPath());
  }

  public static function hasLocalHaxelibRepo() {
    return FileSystem.isDirectory(getLocalHaxelibRepoPath());
  }

  public static function getVersion() : String {
    var path = Path.join([Shell.hmmDirectory, "haxelib.json"]);
    var content = File.getContent(path);
    var data = Json.parse(content);
    return data.version;
  }

  public static function readHmmJson() : HmmConfigFile {
    var path = getHmmJsonPath();
    var text = File.getContent(path);
    return cast Json.parse(text);
  }
}
