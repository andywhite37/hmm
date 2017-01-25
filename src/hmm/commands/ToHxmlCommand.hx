package hmm.commands;

import hmm.HmmConfig;
import hmm.utils.Log;
import hmm.utils.Shell;

class ToHxmlCommand implements ICommand {
  public var type = "to-hxml";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    var config = HmmConfigs.readHmmJsonOrThrow();
    for (lib in config.dependencies) {
      var str = switch lib {
        case Haxelib(name, Some(version)): '${name}:${version}';
        case Haxelib(name, None) : '${name}';
        case Git(name, _, _, _) : '${name}'; // can't provide version info for git dep
        case Mercurial(name, _, _, _) : '${name}'; // can't provide version info for mercurial dep
        case Dev(name, _) : '${name}';
      };
      Log.println('-lib $str');
    }
  }

  public function getUsage() {
    return 'dumps the libraries in hmm.json in a `-lib name[:version]` format for use in an .hxml file';
  }
}
