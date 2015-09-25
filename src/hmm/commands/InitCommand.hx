package hmm.commands;

import haxe.Json;
import hmm.utils.Shell;
import hmm.HmmConfig;
import sys.io.File;

class InitCommand implements ICommand {
  public var type(default, null) = "init";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.createLocalHaxelibRepoIfNotExists();
    Shell.createHmmJsonIfNotExists();
  }

  public function getUsage() {
    return 'initializes the current working directory for hmm usage';
  }
}
