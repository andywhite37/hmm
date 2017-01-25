package hmm.commands;

using StringTools;

import thx.Nil;
import thx.Validation;

import hmm.HmmConfig;
import hmm.LibraryConfig;
import hmm.errors.ValidationError;
import hmm.utils.Shell;
import hmm.utils.Log;

class CheckCommand implements ICommand {
  public var type(default, null) = "check";

  public function new() {
  }

  public function run(args : Array<String>) : Void {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();
    var config = HmmConfigs.readHmmJsonOrThrow();

    var checks = 0;
    var successes : Array<LibraryConfig> = [];
    var failures : Array<LibraryConfig> = [];
    for (library in config.dependencies) {
      checks++;
      if (Shell.isAlreadyInstalled(library, { log: false, throwError: false })) {
        successes.push(library);
      } else {
        failures.push(library);
      }
    }

    if (failures.length > 0) {
      var librariesText = failures.length == 1 ? "library is" : "libraries are";
      var hasText = failures.length == 1 ? "has" : "have";
      var names = failures.map(LibraryConfigs.getName).join(", ");
      throw new ValidationError('${failures.length} $librariesText not installed, or $hasText the wrong version: $names', 1);
    } else {
      var librariesText = successes.length == 1 ? "library is" : "libraries are";
      Log.info('${successes.length} out of ${checks} $librariesText installed at the specified version');
    }
  }

  public function getUsage() {
    return "checks if the current .haxelib installations match the hmm.json-specified versions/refs/etc.";
  }
}
