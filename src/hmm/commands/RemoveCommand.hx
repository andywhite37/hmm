package hmm.commands;

import hmm.utils.Shell;
import hmm.utils.Log;
import sys.FileSystem;
import sys.io.File;

class RemoveCommand implements ICommand {
  public var type(default, null) = "remove";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();

    if (args.length == 0) {
      Log.die('$type command requires 1 or more arguments');
    }

    for (name in args) {
      HmmConfig.removeDependency(name);
      Shell.haxelibRemove(name);
    }

    Shell.haxelibList();
  }

  public function getUsage() {
    return 'removes one or more library dependencies from hmm.json, and removes them via `haxelib remove`

        usage: hmm remove <name> [name2 name3 ...]

        arguments:
        - name - the name of the library to remove (required)
        - name2 name3 ... - additional library names to remove

        example:

        hmm remove thx.core
        hmm remove thx.core mithril
';
  }
}

