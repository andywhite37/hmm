package hmm.commands;

import haxe.Json;
import haxe.io.Path;

import sys.io.File;

import hmm.HmmConfig;
import hmm.utils.Shell;
import hmm.utils.Log;

class VersionCommand implements ICommand {
  public var type(default, null) = "version";

  public function new() {
  }

  public function run(args : Array<String>) {
    Log.println(HmmConfigs.getVersion());
  }

  public function getUsage() {
    return 'print hmm version';
  }
}
