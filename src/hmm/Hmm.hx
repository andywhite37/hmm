package hmm;

import hmm.commands.*;
import hmm.utils.Log;
import hmm.utils.Shell;
using Lambda;

class Hmm {
  public static var commandMap(default, null) : Map<String, ICommand>;

  public static function main() {
    var args = Sys.args();

    var commands : Array<ICommand> = [
      new SetupCommand(),
      new CleanCommand(),
      new InstallCommand(),
      new UpdateCommand()
    ];

    var commandType = "";

    Shell.hmmDirectory = Sys.getCwd();

    if (args.length == 2) {
      // When running via `haxelib run` the current working directory is added to the end of the args list.
      // Also, Sys.getCwd() gets the location of the haxelib install not the actual working directory.
      Shell.workingDirectory = args.pop();
      commandType = args.pop();
    } else if (args.length == 1) {
      Shell.workingDirectory = Sys.getEnv("PWD");
      commandType = args.pop();
    } else {
      showUsage();
    }

    var command = commands.find(function(command) {
      return command.type == commandType;
    });
    if (command == null) {
      Log.error('Invalid command: $commandType');
      Sys.exit(1);
    }

    command.run();
  }

  static function showUsage() {
    Log.info("usage: haxelib run hmm [command]");
    Log.info("");
    Log.info("  command:       one of install, update, clean");
    Sys.exit(1);
  }
}

