package hmm.utils;

import haxe.io.Path;
import sys.FileSystem;
using hmm.utils.AnsiColors;

class Shell {
  public static var hmmDirectory(default, default) : String = "";
  public static var workingDirectory(default, default) : String = "";

  public static function checkWorkingDirectory() {
    Sys.setCwd(workingDirectory);
    Log.info('working directory: $workingDirectory');
    Log.info('hmm install directory: $hmmDirectory');
    if (!HmmConfig.hasHmmFile()) {
      Log.error('No ${HmmConfig.HMM_JSON_FILE_NAME} found in current workding directory - aborting.');
      Sys.exit(1);
    }
    Log.info('local ${HmmConfig.HMM_JSON_FILE_NAME} file exists');
    haxelibCreateRepoIfNeeded();
  }

  public static function haxelibCreateRepoIfNeeded() : Int {
    var path = HmmConfig.getHaxelibRepoPath();
    if (FileSystem.isDirectory(path)) {
      Log.info('local ${HmmConfig.HAXELIB_REPO_DIR_NAME} repo exists');
      return 0;
    }
    return haxelibCreateRepo();
  }

  public static function haxelibCreateRepo() : Int {
    return haxelib(["newrepo"]);
  }

  public static function haxelibRemoveRepoIfExists() {
    if (HmmConfig.hasHaxelibRepo()) {
      var path = HmmConfig.getHaxelibRepoPath();
      return command("rm", ["-rf", path]); // TODO: windows support
    }
    return 0;
  }

  public static function haxelibInstall(name : String, ?version : String) : Int {
    var args = ["install", name];
    if (version != null) args.push(version);
    return haxelib(args);
  }

  public static function haxelibUpdate(name : String) : Int {
    var args = ["update", name];
    return haxelib(args);
  }

  public static function haxelibGit(name : String, url : String, ?ref : String, ?dir : String) : Int {
    var args = ["git", name, url];
    if (ref != null) args.push(ref);
    if (dir != null) args.push(dir);
    return haxelib(args);
  }

  public static function haxelibHg(name : String, url : String, ?ref : String, ?dir : String) : Int {
    var args = ["hg", name, url];
    if (ref != null) args.push(ref);
    if (dir != null) args.push(dir);
    return haxelib(args);
  }

  public static function haxelibList() {
    return haxelib(["list"]);
  }

  public static function haxelib(args : Array<String>) : Int {
    return command("haxelib", args);
  }

  public static function symbolicLink(realPath : String, linkPath : String) {
    if (FileSystem.exists(linkPath)) {
      command("sudo", ["rm", linkPath]);
    }
    command("sudo", ["ln", "-s", realPath, linkPath]);
  }

  public static function command(cmd : String, ?args : Array<String>) : Int {
    Log.shell('$cmd ${args.join(" ")}'.yellow());
    //return 0;
    return Sys.command(cmd, args);
  }
}
