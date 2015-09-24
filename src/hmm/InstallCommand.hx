package hmm;

import mcli.CommandLine;
import sys.FileSystem;
import sys.io.File;

class InstallCommand extends CommandLine {
  public function runDefault() {
    Command.haxelibCreateRepoIfNeeded();
    var config = HmmConfig.read();
    for (library in config.dependencies) {
      install(library);
    }
  }

  function install(library : LibraryConfig) {
    return switch library.type {
      case Haxelib: Command.haxelibInstall(library.name, library.version);
      case Git: Command.haxelibGit(library.name, library.url, library.ref, library.dir);
      case Mercurial: Command.haxelibHg(library.name, library.url, library.ref, library.dir);
    };
  }
}

