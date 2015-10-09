package hmm.commands;

import hmm.utils.Log;
import hmm.utils.Shell;

class ToHxmlCommand implements ICommand {
  public var type = "to-hxml";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();

    var config = HmmConfig.readHmmJson();

    for (lib in config.dependencies) {
      var str = switch lib.type {
        case Haxelib: lib.version != null ? '${lib.name}:${lib.version}' : '${lib.name}';
        case Git | Mercurial: lib.name;
      };
      Log.println('-lib $str');
    }
  }

  public function getUsage() {
    return 'dumps the libraries in hmm.json in a `-lib name[:version]` format for use in an .hxml file';
  }
}
