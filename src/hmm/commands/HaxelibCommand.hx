package hmm.commands;

import hmm.utils.Shell;
import hmm.utils.Log;
import sys.FileSystem;
import sys.io.File;

class HaxelibCommand implements ICommand {
  public var type(default, null) = "haxelib";

  public static var DEFAULT_VERSION = "";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();

    if (args.length < 1 || args.length > 2) {
      Log.die('$type command requires 1 or 2 arguments (<name> [version])');
    }

    var name = args[0];
    var version = DEFAULT_VERSION;

    if (args.length == 2) {
      version = args[1];
    }

    HmmConfig.addHaxelibDependency(name, version);
    Shell.haxelibInstall(name, version);
    Shell.haxelibList();
  }

  public function getUsage() {
    return 'adds a lib.haxe.org-based dependency to hmm.json, and installs the dependency using `haxelib install`

        usage: hmm $type <name> [version]

        arguments:
        - name - the name of the library (required)
        - version - the version to install (default: "")

        example:

        hmm haxelib thx.core
        - adds and installs the current version of thx.core (no version specified)

        hmm haxelib thx.core 1.2.3
        - adds and installs thx.core version 1.2.3';
  }
}

