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
      new VersionCommand(),
      new SetupCommand(),
      new InitCommand(),
      new InstallCommand(),
      new HaxelibCommand(),
      new GitCommand(),
      new HgCommand(),
      new UpdateCommand(),
      new RemoveCommand(),
      new CleanCommand(),
      new HmmUpdateCommand(),
      new HmmRemoveCommand(),
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
      printUsageAndExit();
      Sys.exit(1);
    }

    //Log.info("hmm");
    //Log.info('working directory:  ${Shell.workingDirectory}');
    //Log.info('hmm directory:      ${Shell.hmmDirectory}');
    //Log.info('command:            $commandType');

    command.run(args);
  }

  public static function printUsageAndExit() {
    Log.println("Usage: hmm <command> [options]");
    Log.println("");
    Log.println("commands:");
    Log.println("");
    for (command in commands) {
      Log.println('    ${command.type} - ${command.getUsage()}');
      Log.println("");
    }
    Sys.exit(1);
  }
}

