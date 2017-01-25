package hmm.commands;

using StringTools;
import haxe.ds.Option;

import sys.FileSystem;
import sys.io.File;

using thx.Functions;
using thx.Options;

import hmm.HmmConfig;
import hmm.LibraryConfig;
import hmm.errors.ValidationError;
import hmm.utils.Shell;
import hmm.utils.Log;

class HaxelibCommand implements ICommand {
  public var type(default, null) = "haxelib";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();

    if (args.length < 1 || args.length > 2) {
      throw new ValidationError('$type command requires 1 or 2 arguments (<name> [version])', 1);
    }

    var name : String = args[0];
    var version : Option<String> = None;

    if (args.length == 2) {
      version = Options.ofValue(args[1]).filter.fn(_.trim() != "");
    }

    HmmConfigs.addDependencyOrThrow(Haxelib(name, version));
    Shell.haxelibInstall(name, version, { log: true, throwError: true });
    Shell.haxelibList({ log: true, throwError: true });
  }

  public function getUsage() {
    return 'adds a lib.haxe.org-based dependency to hmm.json, and installs the dependency using `haxelib install`

        usage: hmm $type <name> [version]

        arguments:
        - name - the name of the library (required)
        - version - the version to install (optional)

        example:

        hmm haxelib thx.core
        - adds and installs the current version of thx.core (no version specified)

        hmm haxelib thx.core 1.2.3
        - adds and installs thx.core version 1.2.3';
  }
}

