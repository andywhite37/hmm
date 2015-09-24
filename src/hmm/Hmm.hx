package hmm;

import hmm.commands.*;
import hmm.utils.Log;
import hmm.utils.Shell;
using Lambda;

class Hmm {
  public static var commands(default, null) : Array<ICommand>;

  public static function main() {
    var args = Sys.args();

    commands = [
      new HelpCommand(),
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
      printUsage();
    }

    var command = commands.find(function(command) {
      return command.type == commandType;
    });

    if (command == null) {
      Log.error('invalid command: $commandType');
      printUsage();
      Sys.exit(1);
    }

    command.run();
  }

  public static function printUsage() {
    Log.info("Usage: hmm [command] [options]");
    Log.info("");
    Log.info("Commands:");
    Log.info("");
    for (command in commands) {
      Log.info('    ${command.type} - ${command.getUsage()}');
    }
    Log.info("");
    Sys.exit(1);
  }
}

