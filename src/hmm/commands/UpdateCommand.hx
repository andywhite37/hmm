package hmm.commands;

import hmm.utils.Shell;
import sys.FileSystem;
import sys.io.File;

class UpdateCommand implements ICommand {
  public function new() {
  }

  public function run() {
    Shell.checkWorkingDirectory();
    var config = HmmConfig.read();
    for (library in config.dependencies) {
      Shell.haxelibUpdate(library.name);
    }
    Shell.haxelibList();
  }
}

