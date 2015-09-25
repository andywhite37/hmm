package hmm;

import hmm.commands.*;
import hmm.utils.Log;
import hmm.utils.Shell;
using Lambda;

class Hmm {
  public static var commands(default, null) : Array<ICommand>;

  public static function main() {
    commands = [
      new HelpCommand(),
      new SetupCommand(),
      new CleanCommand(),
      new InstallCommand(),
      new UpdateCommand()
    ];

    var args = Sys.args();

    Shell.init({
      hmmDirectory: Sys.getCwd(),
      workingDirectory: args.pop()
    });

    var commandType = args.shift();

    var command = commands.find(function(command) {
      return command.type == commandType;
    });

    if (command == null) {
      Log.error('invalid command: $commandType');
      printUsage();
      Sys.exit(1);
    }

    Log.info("hmm");
    Log.info('working directory:  ${Shell.workingDirectory}');
    Log.info('hmm directory:      ${Shell.hmmDirectory}');
    Log.info('command:            $commandType');

    command.run(args);
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

