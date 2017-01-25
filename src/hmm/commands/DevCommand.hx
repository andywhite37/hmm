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

class DevCommand implements ICommand {
  public var type(default, null) = "dev";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();

    if (args.length != 2) {
      throw new ValidationError('$type command requires 2 arguments: <name> and <path>', 1);
    }

    var name : String = args[0];
    var path : String = args[1];

    // Add the library to the hmm.json
    HmmConfigs.addDependencyOrThrow(Dev(name, path));

    // Install the library
    Shell.haxelibDev(name, path, { log: true, throwError: true });

    // Show the resulting haxelib list
    Shell.haxelibList({ log: true, throwError: true });
  }

  public function getUsage() {
    return 'adds a "dev" dependency to hmm.json, and installs the dependency using `haxelib dev`

        usage: hmm dev <name> <path>

        arguments:
        - name - the name of the library (required)
        - path - the file system path to the library (required)

        example:

        hmm dev thx.core /my/path/thx.core
';
  }
}

