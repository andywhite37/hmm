package hmm.commands;

import hmm.HmmConfig;
import hmm.utils.Log;
import hmm.utils.Shell;
import sys.FileSystem;
import sys.io.File;

class FromHxmlCommand implements ICommand {
  public var type = "from-hxml";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();

    if (args.length == 0) {
      Log.die('$type requires at least one argument (path to .hxml file)');
    }

    for (path in args) {
      var libs = readLibsFromHxml(path);
      for (lib in libs) {
        HmmConfig.addHaxelibDependency(lib.name, lib.version);
      }
    }
  }

  function readLibsFromHxml(path : String) : Array<{ name: String, ?version : String }> {
    var content = File.getContent(path);

    var lines = content.split("\n");

    return lines
      .filter(function(line) {
        return ~/^[ \t]*-lib[ \t]+([^:]*)(:(.*))?$/.match(line);
      })
      .map(function(line) {
        var regex = ~/^[ \t]*-lib[ \t]+([^:]*)(:(.*))?$/;
        regex.match(line);
        var name = regex.matched(1);
        var version = try {
          regex.matched(3);
        } catch (e : Dynamic) {
          "";
        }
        return {
          name: name,
          version: version
        };
    });
  }

  public function getUsage() {
    return 'reads -lib lines specified in one or more .hxml files and adds them to hmm.json

        usage: hmm from-hxml <hxml-path> [hxml-path2 hxml-path3 ...]

        example:
        hmm from-hxml build.hxml
        - adds dependencies in hmm.json for each -lib line in build.hxml';
  }
}
