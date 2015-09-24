package hmm.commands;

import hmm.utils.Shell;
import mcli.CommandLine;
import sys.FileSystem;
import sys.io.File;

class InstallCommand extends CommandLine {
  public function runDefault() {
    Shell.checkWorkingDirectory();
    var config = HmmConfig.read();
    for (library in config.dependencies) {
      install(library);
    }
    Shell.haxelibList();
  }

  function install(library : LibraryConfig) {
    return switch library.type {
      case Haxelib: Shell.haxelibInstall(library.name, library.version);
      case Git: Shell.haxelibGit(library.name, library.url, library.ref, library.dir);
      case Mercurial: Shell.haxelibHg(library.name, library.url, library.ref, library.dir);
    };
  }
}

