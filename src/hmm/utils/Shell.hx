package hmm.utils;

import haxe.Json;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
using StringTools;
using hmm.utils.AnsiColors;

class Shell {
  public static var hmmDirectory(default, default) : String;
  public static var workingDirectory(default, default) : String;

  public static function init(options : { hmmDirectory : String, workingDirectory : String}) {
    hmmDirectory = options.hmmDirectory;
    workingDirectory = options.workingDirectory;
    Sys.setCwd(workingDirectory);
  }

  public static function ensureHmmJsonExists() : Void {
    if (!HmmConfig.hasHmmJson()) {
      Log.die('${HmmConfig.HMM_JSON_FILE_NAME} not found in current workding directory - aborting.');
    }
    //Log.info('${HmmConfig.HMM_JSON_FILE_NAME} file exists, continuing');
  }

  public static function createHmmJsonIfNotExists() {
    if (HmmConfig.hasHmmJson()) {
      //Log.info('${HmmConfig.HMM_JSON_FILE_NAME} already exists');
      return;
    }
    var path = HmmConfig.getHmmJsonPath();
    Log.shell('creating $path');
    File.saveContent(path, Json.stringify({ dependencies: [] }, null, '  '));
  }

  public static function addDependecyToHmmJson(library : LibraryConfig) {
  }

  public static function createLocalHaxelibRepoIfNotExists() : Void {
    if (HmmConfig.hasLocalHaxelibRepo()) {
      //Log.info('local ${HmmConfig.HAXELIB_REPO_DIR_NAME} repo exists, continuing');
      return;
    }
    haxelibNewRepo();
  }

  public static function removeLocalHaxelibRepoIfExists() : Void {
    if (HmmConfig.hasLocalHaxelibRepo()) {
      var path = HmmConfig.getLocalHaxelibRepoPath();
      command("rm", ["-rf", path]); // TODO: windows support
    }
  }

  public static function haxelibNewRepo() : Void {
    return haxelib(["newrepo"]);
  }

  public static function haxelibInstall(name : String, ?version : String) : Void {
    var args = ["install", name];
    if (version != null) args.push(version);
    return haxelib(args);
  }

  public static function haxelibUpdate(name : String) : Void {
    var args = ["update", name];
    return haxelib(args);
  }

  public static function haxelibRemove(name : String) : Void {
    var args = ["remove", name];
    return haxelib(args);
  }

  public static function haxelibGit(name : String, url : String, ?ref : String, ?dir : String) : Void {
    var args = ["git", name, url];
    if (ref != null) args.push(ref);
    if (dir != null) args.push(dir);
    return haxelib(args);
  }

  public static function haxelibHg(name : String, url : String, ?ref : String, ?dir : String) : Void {
    var args = ["hg", name, url];
    if (ref != null) args.push(ref);
    if (dir != null) args.push(dir);
    haxelib(args);
  }

  public static function haxelibList() : Void {
    haxelib(["list"]);
  }

  public static function haxelibPath(libraryName : String) : { isInstalled: Bool, ?path: String, ?libraryName: String, ?version: String } {
    var process = new Process("haxelib", ["path", libraryName]);
    var outputString = process.stdout.readAll().toString();
    var outputLines = outputString.split("\n");
    var result = { isInstalled: false, path: null, libraryName: null, version: null };
    for (outputLine in outputLines) {
      if (~/is not installed/i.match(outputLine)) {
        result.isInstalled = false;
        return result;
      } else if (outputLine.startsWith("/")) {
        result.isInstalled = true;
        result.path = outputLine;
      } else {
        result.isInstalled = true;
        var regex = ~/^\s*-D\s*(.*)=(.*)\s*$/;
        if (regex.match(outputLine)) {
          result.libraryName = regex.matched(1);
          result.version = regex.matched(2);
        }
      }
    }
    return result;
  }

  public static function haxelib(args : Array<String>) : Void {
    command("haxelib", args);
  }

  public static function createHmmLink(realPath : String, linkPath : String) : Void {
    command("chmod", ["+x", realPath]);
    command("sudo", ["rm", linkPath]);
    command("sudo", ["ln", "-s", realPath, linkPath]);
  }

  public static function updateHmm() {
    haxelib(["--global", "update", "hmm"]);
    haxelib(["--global", "run", "hmm", "setup"]);
  }

  public static function removeHmm() {
    command("sudo", ["rm", hmm.commands.SetupCommand.HMM_LINK_PATH]);
    haxelib(["--global", "remove", "hmm"]);
  }

  public static function gitRevParse(path : String, ref : String) : String {
    var oldCwd = Shell.workingDirectory;
    Sys.setCwd(path);
    var hash = new Process("git", ["rev-parse", ref]).stdout.readAll().toString().replace("\n", "");
    Sys.setCwd(oldCwd);
    return hash;
  }

  public static function command(cmd : String, ?args : Array<String>) : Void {
    Log.shell('$cmd ${args.join(" ")}');
    Sys.command(cmd, args);
  }
}
