package hmm.commands;

import haxe.Json;
import haxe.io.Path;
import hmm.utils.Shell;
import hmm.utils.Log;
import sys.io.File;

class VersionCommand implements ICommand {
  public var type(default, null) = "version";

  public function new() {
  }

  public function run(args : Array<String>) {
    Log.println(HmmConfig.getVersion());
  }

  public function getUsage() {
    return 'print hmm version';
  }
}
