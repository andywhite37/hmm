package hmm.commands;

import hmm.utils.Shell;

class CleanCommand implements ICommand {
  public var type(default, null) = "clean";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.removeLocalHaxelibRepoIfExists();
  }

  public function getUsage() {
    return "removes local .haxelib directory";
  }
}
