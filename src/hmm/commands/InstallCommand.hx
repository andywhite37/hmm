package hmm.commands;

import sys.FileSystem;
import sys.io.File;

import hmm.HmmConfig;
import hmm.utils.Shell;

class InstallCommand implements ICommand {
  public var type(default, null) = "install";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();
    var config = HmmConfigs.readHmmJsonOrThrow();
    for (library in config.dependencies) {
      install(library);
    }
    Shell.haxelibList({ log: true, throwError: true });
  }

  function install(library : LibraryConfig) {
    return switch library {
      case Haxelib(name, version): Shell.haxelibInstall(name, version, { log: true, throwError: true });
      case Git(name, url, ref, dir): Shell.haxelibGit(name, url, ref, dir, { log: true, throwError: true });
      case Mercurial(name, url, ref, dir): Shell.haxelibHg(name, url, ref, dir, { log: true, throwError: true });
      case Dev(name, path) : Shell.haxelibDev(name, path, { log: true, throwError: true });
    };
  }

  public function getUsage() {
    return "installs libraries listed in hmm.json";
  }
}

