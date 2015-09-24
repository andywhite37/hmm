package hmm;

import haxe.io.Path;
import sys.FileSystem;

class Command {
  public static function haxelibCreateRepoIfNeeded() : Int {
    var path = HmmConfig.getHaxelibRepoPath();
    if (FileSystem.isDirectory(path)) {
      log("local .haxelib repo already exists");
      return 0;
    }
    return haxelibCreateRepo();
  }

  public static function haxelibCreateRepo() : Int {
    return haxelib(["newrepo"]);
  }

  public static function haxelibRemoveRepo() {
    var path = HmmConfig.getHaxelibRepoPath();
    //return FileSystem.deleteDirectory(path);
    //trace(path);
    return exec("rm", ["-r", path]);
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

  public static function haxelib(args : Array<String>) : Int {
    return exec("haxelib", args);
  }

  public static function exec(cmd : String, ?args : Array<String>) : Int {
    Sys.println(cmd + " " + args.join(" "));
    //return 0;
    return Sys.command(cmd, args);
  }

  public static function log(string : String) {
    Sys.println(string);
  }
}
