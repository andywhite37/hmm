package hmm.commands;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import hmm.utils.Shell;

class SetupCommand implements ICommand {
  public static var HMM_LINK_PATH = "/usr/local/bin/hmm";

  public var type(default, null) = "setup";

  public function new() {
  }

  public function run() {
    Shell.symbolicLink(getHmmScriptFilePath(), HMM_LINK_PATH);
  }

  function getHmmScriptFilePath() {
    return Path.join([Shell.hmmDirectory, "hmm"]);
  }
}
