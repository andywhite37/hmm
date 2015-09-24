package hmm;

import hmm.commands.*;
import hmm.utils.Log;
import hmm.utils.Shell;

class Hmm {
  public static var commands(default, null) : Map<String, ICommand>;

  public static function main() {
    trace('Sys.args = ${Sys.args()}');

    commands = [
      "clean" => new CleanCommand(),
      "install" => new InstallCommand(),
      "update" => new UpdateCommand()
    ];

    var command = "";

    if (Sys.args().length == 2) {
      // When running via `haxelib run` the current working directory is added to the end of the args list.
      // Also, Sys.getCwd() gets the location of the haxelib install not the actual working directory.
      Shell.workingDirectory = Sys.args().pop();
      command = Sys.args().pop();
    } else if (Sys.args().length == 1) {
      Shell.workingDirectory = Sys.getEnv("PWD");
      command = Sys.args().pop();
    } else {
      showUsage();
    }

    trace(commands);
    trace(command);

    commands[command].run();
  }

  static function showUsage() {
    Log.info("usage: haxelib run hmm [command]");
    Log.info("");
    Log.info("  command:       one of install, update, clean");
    Sys.exit(1);
  }
}

