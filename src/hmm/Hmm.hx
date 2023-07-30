package hmm;

using Lambda;
using thx.Functions;

import hmm.commands.*;
import hmm.errors.*;
import hmm.utils.Args;
import hmm.utils.Log;
import hmm.utils.Shell;

class Hmm {
  public static var commands(default, null):Array<ICommand>;

  public static function main() {
    try {
      commands = [
        new HelpCommand(), new VersionCommand(), new SetupCommand(), new InitCommand(), new FromHxmlCommand(), new ToHxmlCommand(), new InstallCommand(),
        new ReinstallCommand(), new HaxelibCommand(), new GitCommand(), new HgCommand(), new DevCommand(), new UpdateCommand(), new RemoveCommand(),
        new LockVersionCommand(), new CheckCommand(), new CleanCommand(), new HmmUpdateCommand(), new HmmRemoveCommand(),
      ];

      var args = Sys.args().copy();

      Shell.init({
        hmmDirectory: Sys.getCwd(),
        workingDirectory: args.pop(),
        isWin: Sys.systemName() == "Windows",
        isQuiet: Args.hasAny(args, ['--quiet', '-q']),
      });

      var commandType = args.shift();
      if (commandType == null) {
        throw new ValidationError('no command given', 1);
      }

      var command = commands.find(function(command) {
        return command.type == commandType;
      });

      if (command == null) {
        throw new ValidationError('unrecognized command: $commandType', 1);
      }

      command.run(args);
    } catch (e:ValidationError) {
      die('Validation error: ${e.message}', e.statusCode);
    } catch (e:SystemError) {
      die('Execution error: ${e.message}', e.statusCode);
    } catch (e:Dynamic) {
      die('Unexpected error: $e', 1);
    }
  }

  static function die(message:String, statusCode:Int):Void {
    Log.error(message);
    Log.println('Use "hmm help" to see usage');
    Sys.exit(statusCode);
  }

  public static function printUsageAndExit(statusCode:Int):Void {
    Log.println("Usage: hmm <command> [options]");
    Log.println("");
    Log.println("commands:");
    Log.println("");
    printUsagesAndExit(commands.map(a -> a.type), statusCode);
  }

  public static function printUsagesAndExit(types:Array<String>, statusCode:Int):Void {
    for (type in types) {
      var command = commands.find(a -> a.type == type);
      if (command == null) {
        throw new ValidationError('invalid command: $type', 1);
      }
      Log.println('    ${command.type} - ${command.getUsage()}');
      Log.println("");
    }
    Sys.exit(statusCode);
  }
}
