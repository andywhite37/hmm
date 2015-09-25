package hmm.commands;

import hmm.utils.Shell;
import sys.FileSystem;
import sys.io.File;

class UpdateCommand implements ICommand {
  public var type(default, null) = "update";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.ensureLocalHaxelibRepoExists();

    var config = HmmConfig.readHmmJson();

    for (library in config.dependencies) {
      Shell.haxelibUpdate(library.name);
    }

    Shell.haxelibList();
  }

  public function getUsage() {
    return "updates libraries listed in hmm.json";
  }
}

