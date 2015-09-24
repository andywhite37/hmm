package hmm.commands;

import hmm.utils.Shell;
import mcli.CommandLine;
import sys.FileSystem;
import sys.io.File;

class UpdateCommand extends CommandLine {
  public function runDefault() {
    Shell.checkWorkingDirectory();
    var config = HmmConfig.read();
    for (library in config.dependencies) {
      Shell.haxelibUpdate(library.name);
    }
    Shell.haxelibList();
  }
}

