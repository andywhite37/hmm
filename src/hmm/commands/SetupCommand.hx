package hmm.commands;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import hmm.utils.Shell;

class SetupCommand implements ICommand {
  public static var HMM_FILE_NAME = "hmm";
  public static var HMM_LINK_PATH = "/usr/local/bin/hmm";

  public var type(default, null) = "setup";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.createHmmLink(getHmmScriptFilePath(), HMM_LINK_PATH);
  }

  function getHmmScriptFilePath() {
    return Path.join([Shell.hmmDirectory, HMM_FILE_NAME]);
  }

  public function getUsage() {
    return 'creates a symbolic link to $HMM_FILE_NAME at $HMM_LINK_PATH';
  }
}
