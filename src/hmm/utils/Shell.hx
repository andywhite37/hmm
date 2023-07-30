package hmm.utils;

using StringTools;
import haxe.Json;
import haxe.ds.Option;
import haxe.io.Path;

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

using thx.Options;

import hmm.HmmConfig;
import hmm.errors.SystemError;
import hmm.errors.ValidationError;
using hmm.utils.AnsiColors;

typedef ShellOptions = {
  log: Bool,
  throwError: Bool
};

typedef ShellInitOptions = {
  hmmDirectory : String, 
  workingDirectory : String,
  isWin : Bool,
  isQuiet: Bool,
}

class Shell {
  public static var hmmDirectory(default, default) : String;
  public static var workingDirectory(default, default) : String;
  public static var isWin(default, default) : Bool;
  public static var isQuiet(default, default) : Bool;

  public static function init(options : ShellInitOptions) : Void {
    hmmDirectory = options.hmmDirectory;
    workingDirectory = options.workingDirectory;
    isWin = options.isWin;
    isQuiet = options.isQuiet;
    AnsiColors.disabled = isWin;
    setCwd(workingDirectory, { log: false });
  }

  public static function ensureHmmJsonExists() : Void {
    if (!HmmConfigs.hasHmmJson()) {
      throw new ValidationError('${HmmConfigs.HMM_JSON_FILE_NAME} not found in current working directory', 1);
    }
  }

  public static function createHmmJsonIfNotExists() : Void {
    if (HmmConfigs.hasHmmJson()) {
      return;
    }
    var path = HmmConfigs.getHmmJsonPath();
    Log.shell('initializing: $path');
    File.saveContent(path, Json.stringify({ dependencies: [] }, null, '  '));
  }

  public static function createLocalHaxelibRepoIfNotExists() : Void {
    if (!HmmConfigs.hasLocalHaxelibRepo()) {
      haxelibNewRepo({ log: true, throwError: true });
    }
  }

  public static function removeLocalHaxelibRepoIfExists() : Void {
    if (HmmConfigs.hasLocalHaxelibRepo()) {
      haxelibDeleteRepo({ log: true, throwError: true });
    }
  }

  public static function haxelibNewRepo(options: ShellOptions) : Void {
    return haxelib(["newrepo"], options);
  }

  public static function haxelibDeleteRepo(options: ShellOptions) : Void {
    return haxelib(["deleterepo"], options);
  }

  public static function haxelibInstall(name : String, version : Option<String>, options: ShellOptions) : Void {
    var args = ["install", name].concat(version.toArray());
    return haxelib(args, options);
  }

  public static function haxelibUpdate(name : String, options: ShellOptions) : Void {
    var args = ["update", name];
    return haxelib(args, options);
  }

  public static function haxelibRemove(name : String, options: ShellOptions) : Void {
    var args = ["remove", name];
    return haxelib(args, options);
  }

  public static function haxelibGit(name : String, url : String, ref : Option<String>, dir : Option<String>, options: ShellOptions) : Void {
    var args = ["git", name, url].concat(ref.toArray()).concat(dir.toArray());
    return haxelib(args, options);
  }

  public static function haxelibHg(name : String, url : String, ref : Option<String>, dir : Option<String>, options: ShellOptions) : Void {
    var args = ["hg", name, url].concat(ref.toArray()).concat(dir.toArray());
    haxelib(args, options);
  }

  public static function haxelibDev(name : String, path : String, options: ShellOptions) : Void {
    var args = ["dev", name, path];
    return haxelib(args, options);
  }

  public static function haxelibList(options: ShellOptions) : Void {
    haxelib(["list"], options);
  }

  public static function haxelibPath(libraryName : String, options: ShellOptions) : { statusCode: Int, isInstalled: Bool, ?path: String, ?libraryName: String, ?version: String } {
    var commandResult = readCommand("haxelib", ["path", libraryName], options);
    var outputString = commandResult.stdout;
    var outputLines = outputString.split("\n");
    var result = { statusCode: commandResult.statusCode, isInstalled: false, path: null, libraryName: null, version: null };
    var notInstalledRegex = ~/is not installed/i;
    var versionRegex = ~/^\s*-D\s*(.*)=(.*)\s*$/;
    var pathRegex = ~/^(\/|[A-Z]:)/;
    for (line in outputLines) {
      var outputLine = line.trim();
      if (notInstalledRegex.match(outputLine)) {
        result.isInstalled = false;
        return result;
      }
      result.isInstalled = true;
      if (result.path == null && pathRegex.match(outputLine)) {
        // capture the path to the library if it has not yet been captured
        result.path = outputLine;
      } else if (result.libraryName == null && result.version == null && versionRegex.match(outputLine)) {
        result.libraryName = versionRegex.matched(1);
        result.version = versionRegex.matched(2);
      }
      if (result.isInstalled && result.path != null && result.libraryName != null && result.version != null) {
        return result;
      }
    }
    throw new SystemError('failed to extract expected "haxelib path $libraryName" information (path, name, and version) for library: $libraryName', 1);
  }

  public static function haxelib(args : Array<String>, options: ShellOptions) : Void {
    // Always pass the --never option to haxelib, to answer no to all questions
    var commandArgs = ["--never"].concat(args);
    if (isQuiet) {
      commandArgs.push("--quiet");
    }
    runCommand("haxelib", commandArgs, options);
  }

  public static function isAlreadyInstalled(library : LibraryConfig, options: ShellOptions) : Bool {
    return switch library {
      case Haxelib(name, version) : isAlreadyInstalledHaxelib(name, version, options);
      case Git(name, url, ref, dir) : isAlreadyInstalledGit(name, url, ref, dir, options);
      case Mercurial(name, url, ref, dir) : isAlreadyInstalledMercurial(name, url, ref, dir, options);
      case Dev(name, path) : isAlreadyInstalledDev(name, path, options);
    };
  }

  public static function isAlreadyInstalledHaxelib(name : String, version : Option<String>, options: ShellOptions) : Bool {
    var haxelibPathResult = haxelibPath(name, { log: false, throwError: false });
    return if (haxelibPathResult.statusCode != 0) {
      if (options.log) {
        Log.warning('"haxelib path $name" failed - assuming library is not installed');
      }
      false;
    } else if (!haxelibPathResult.isInstalled) {
      if (options.log) {
        Log.warning('haxelib library "$name" does not appear to be installed');
      }
      false;
    } else {
      switch version {
        case None :
          if (options.log) {
            Log.warning('haxelib library "$name" has no specified version, not checking installation version');
          }
          true;
        case Some(version) :
          if (haxelibPathResult.version != version) {
            if (options.log) {
              Log.warning('haxelib library: "$name" (version: "${version}") does not match currently-installed version: "${haxelibPathResult.version}"');
            }
            false;
          } else {
            if (options.log) {
              Log.info('haxelib library "$name" (version: "${version}") is currently installed');
            }
            true;
          }
      };
    }
  }

  public static function isAlreadyInstalledGit(name : String, url : String, ref: Option<String>, dir: Option<String>, options: ShellOptions) : Bool {
    var haxelibPathResult = haxelibPath(name, { log: false, throwError: false });
    return if (haxelibPathResult.statusCode != 0) {
      if (options.log) {
        Log.warning('"haxelib path $name" failed - assuming library is not installed');
      }
      false;
    } else if (!haxelibPathResult.isInstalled) {
      if (options.log) {
        Log.warning('git library "$name" does not appear to be installed');
      }
      false;
    } else {

      // origin isn't guaranteed to be the, well, actual origin. depends on
      // the user. mostly likely suits our needs but may need further
      // consideration later.
      var currRemote = gitRemoteGetUrl(haxelibPathResult.path, "origin", { log: false, throwError: false });
      switch (currRemote) {
        case None :
          if (options.log) {
            Log.warning('git library "$name" has no remote origin, not checking installation url');
          }
          return true;
        case Some(remote) :
          if (remote != url) {
            if (options.log) {
              Log.warning('git library: "$name" (url: "${url}") does not match currently-installed url: "${remote}"');
            }
            return false;
          }
      }

      switch ref {
        case None :
          if (options.log) {
            Log.warning('git library "$name" has no specified ref, not checking installation ref');
          }
          true;
        case Some(ref) :
          var headCommit = gitRevParse(haxelibPathResult.path, "HEAD", { log: false, throwError: false });
          var refCommit = gitRevParse(haxelibPathResult.path, ref, { log: false, throwError: false });
          switch [headCommit, refCommit] {
            case [Some(head), Some(ref)] if (head == ref) :
              if (options.log) {
                Log.info('git library "$name" (ref: "$ref", commit: $refCommit) is currently installed');
              }
              true;
            case [Some(head), Some(ref)] :
              if (options.log) {
                Log.warning('git library "$name" (ref: "$ref", commit: $refCommit) does not match head commit: $head');
              }
              false;
            case [Some(head), None]:
              if (options.log) {
                Log.warning('failed to "git rev-parse $ref", cannot check installation ref');
              }
              false;
            case [None, Some(ref)]:
              if (options.log) {
                Log.warning('failed to "git rev-parse HEAD", cannot check installation ref');
              }
              false;
            case [None, None]:
              if (options.log) {
                Log.warning('failed to "git rev-parse HEAD" and "git rev-parse $ref", cannot check installation ref');
              }
              false;
          }
      }
    }
  }

  public static function isAlreadyInstalledMercurial(name : String, url : String, ref: Option<String>, dir: Option<String>, options: ShellOptions) : Bool {
    // TODO: not sure how to check this in hg, so assume it's not already installed
    if (options.log) {
      Log.warning('hg library "$name" has ref: "$ref" - hg installation check not yet implemented)');
    }
    return false;
  }

  public static function isAlreadyInstalledDev(name : String, path : String, options: ShellOptions) : Bool {
    var haxelibPathResult = haxelibPath(name, { log: false, throwError: false });
    return if (haxelibPathResult.statusCode != 0) {
      if (options.log) {
        Log.warning('"haxelib path $name" failed - assuming library is not installed');
      }
      false;
    } else if (!haxelibPathResult.isInstalled) {
      if (options.log) {
        Log.warning('dev library "$name" does not appear to be installed');
      }
      false;
    } else {
      true;
    }
  }

  public static function createHmmLink(realPath : String, linkPath : String) : Void {
    if (isWin) {
      Log.shell('copy $realPath $linkPath');
      File.saveContent(linkPath, File.getContent(realPath));
    } else {
      runCommand("chmod", ["+x", realPath], { log: true, throwError: true });
      runCommand("sudo", ["rm", linkPath], { log: true, throwError: false });
      runCommand("sudo", ["ln", "-s", realPath, linkPath], { log: true, throwError: true });
    }
  }

  public static function updateHmm() {
    haxelib(["--global", "update", "hmm"], { log: true, throwError: true });
    haxelib(["--global", "run", "hmm", "setup"], { log: true, throwError: true });
  }

  public static function removeHmm() {
    var linkPath = hmm.commands.SetupCommand.getLinkPath();
    if (isWin) {
      runCommand("del", [linkPath], { log: true, throwError: true });
    } else {
      runCommand("sudo", ["rm", linkPath], { log: true, throwError: true });
    }
    haxelib(["--global", "remove", "hmm"], { log: true, throwError: true });
  }

  public static function gitRevParse(path : String, ref : String, options: { log: Bool, throwError: Bool }) : Option<String> {
    var oldCwd = Shell.workingDirectory;
    setCwd(path, options);
    var revParseResult = readCommand("git", ["rev-parse", ref], options);
    setCwd(oldCwd, options);
    return if (revParseResult.statusCode != 0) {
      None;
    } else {
      Some(revParseResult.stdout.replace("\n", ""));
    }
  }

  public static function gitRemoteGetUrl(path : String, remote : String, options: { log: Bool, throwError: Bool }) : Option<String> {
    var oldCwd = Shell.workingDirectory;
    setCwd(path, options);
    var remoteGetUrlResult = readCommand("git", ["remote", "get-url", remote], options);
    setCwd(oldCwd, options);
    return if (remoteGetUrlResult.statusCode != 0) {
      None;
    } else {
      Some(remoteGetUrlResult.stdout.replace("\n", ""));
    }
  }

  static function runCommand(cmd : String, args : Array<String>, options: { log: Bool, throwError: Bool }) : Void {
    var commandString = '$cmd ${args.join(" ")}';
    if (options.log) {
      Log.shell(commandString);
    }
    var statusCode = Sys.command(cmd, args);
    checkStatusCode(statusCode, commandString, options);
  }

  static public function readCommand(cmd : String, args : Array<String>, options: { log: Bool, throwError: Bool }) : { statusCode: Int, stdout: String, stderr: String } {
    var commandString = '$cmd ${args.join(" ")}';
    if (options.log) {
      Log.shell(commandString);
    }
    var process = new Process(cmd, args);
    var statusCode = process.exitCode();
    var stdout = process.stdout.readAll().toString();
    var stderr = process.stderr.readAll().toString();
    /*
    if (stdout != null && stdout.trim() != "") {
      Log.shell(' -> $stdout');
    }
    if (stderr != null && stderr.trim() != "") {
      Log.shell(' -> $stderr');
    }
    */
    checkStatusCode(statusCode, commandString, options);
    return {
      statusCode: statusCode,
      stdout: stdout,
      stderr: stderr
    };
  }

  static function setCwd(path : String, options: { log: Bool }) : Void {
    if (options.log) {
      Log.shell('cd $path');
    }
    Sys.setCwd(path);
  }

  static function checkStatusCode<T>(statusCode : Int, commandString : String, options: { throwError: Bool }) : Void {
    return if (statusCode != 0) {
      if (options.throwError) {
        throw new SystemError('command "$commandString" failed with status: $statusCode in cwd: ${Sys.getCwd()}', 1);
      } else {
        Log.warning('Warning: command "$commandString" failed with status: $statusCode in dir: ${Sys.getCwd()}');
      }
    }
  }
}
