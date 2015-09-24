package hmm.commands;

import hmm.utils.Shell;

class CleanCommand implements ICommand {
  public var type(default, null) = "clean";

  public function new() {
  }

  public function run() {
    Shell.checkWorkingDirectory();
    Shell.haxelibRemoveRepoIfExists();
  }

  public function getUsage() {
    return "removes local .haxelib directory";
  }
}
