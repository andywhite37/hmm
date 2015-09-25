package hmm.commands;

import hmm.utils.Shell;
import sys.FileSystem;
import sys.io.File;

class InstallCommand implements ICommand {
  public var type(default, null) = "install";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.ensureLocalHaxelibRepoExists();

    var config = HmmConfig.readHmmJson();

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

  public function getUsage() {
    return "installs libraries listed in hmm.json";
  }
}

