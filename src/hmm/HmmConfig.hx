package hmm;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

typedef HmmConfigFile = {
  dependencies: Array<LibraryConfig>
};

class HmmConfig {
  public static var HMM_JSON_FILE_NAME = "hmm.json";
  public static var HAXELIB_REPO_DIR_NAME = ".haxelib";

  public static function getHaxelibRepoPath() {
    return Path.join([Sys.getCwd(), HAXELIB_REPO_DIR_NAME]);
  }

  public static function getHmmFilePath() {
    return Path.join([Sys.getCwd(), HMM_JSON_FILE_NAME]);
  }

  public static function hasHaxelibRepo() {
    return FileSystem.isDirectory(getHaxelibRepoPath());
  }

  public static function hasHmmFile(){
    return FileSystem.exists(getHmmFilePath());
  }

  public static function read() : HmmConfigFile {
    var path = getHmmFilePath();
    var rawText = File.getContent(path);
    return cast Json.parse(rawText);
  }
}
