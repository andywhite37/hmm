package hmm.commands;

import sys.FileSystem;
import sys.io.File;

import hmm.HmmConfig;
import hmm.LibraryConfig;
import hmm.utils.Shell;

class UpdateCommand implements ICommand {
  public var type(default, null) = "update";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();
    var config = HmmConfigs.readHmmJsonOrThrow();
    for (library in config.dependencies) {
      Shell.haxelibUpdate(LibraryConfigs.getName(library), { log: true, throwError: true });
    }
    Shell.haxelibList({ log: true, throwError: true });
  }

  public function getUsage() {
    return "updates libraries listed in hmm.json";
  }
}

