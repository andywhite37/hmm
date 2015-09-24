package hmm;

import mcli.CommandLine;
import sys.FileSystem;
import sys.io.File;

class UpdateCommand extends CommandLine {
  public function runDefault() {
    Command.haxelibCreateRepoIfNeeded();
    var config = HmmConfig.read();
    for (library in config.dependencies) {
      Command.haxelibUpdate(library.name);
    }
  }
}

