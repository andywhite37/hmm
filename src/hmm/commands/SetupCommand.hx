package hmm.commands;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

import hmm.utils.Shell;
import hmm.errors.SystemError;

class SetupCommand implements ICommand {

  public var type(default, null) = "setup";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.createHmmLink(getHmmScriptFilePath(), getLinkPath());
  }

  function getHmmScriptFilePath() {
    return Path.join([Shell.hmmDirectory, getHmmFileName()]);
  }

  public function getUsage() {
    return if (Shell.isWin) {
      'creates a ${getHmmFileName()} script at ${getLinkPath()}';
    } else {
      'creates a symbolic link to ${getHmmFileName()} at ${getLinkPath()}';
    }
  }

  public static function getLinkPath() {
    return if (Shell.isWin) {
      Path.join([getHaxePath(), "hmm.cmd"]);
    } else {
      "/usr/local/bin/hmm";
    }
  }

  static function getHaxePath() {
    var haxePath = Sys.getEnv("HAXEPATH");
    if (haxePath == null) throw new SystemError("HAXEPATH environment variable is not defined", 1);
    return haxePath;
  }

  public static function getHmmFileName() {
    return Shell.isWin ? "hmm.cmd" : "hmm";
  }
}
