package hmm.commands;

import haxe.ds.Option;

import sys.FileSystem;
import sys.io.File;

import thx.Options;

import hmm.HmmConfig;
import hmm.errors.ValidationError;
import hmm.utils.Log;
import hmm.utils.Shell;

class FromHxmlCommand implements ICommand {
  public var type = "from-hxml";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();

    if (args.length == 0) {
      throw new ValidationError('$type requires at least one argument (path to .hxml file)', 1);
    }

    for (path in args) {
      var libs = readLibsFromHxml(path);
      for (lib in libs) {
        HmmConfigs.addDependency(Haxelib(lib.name, lib.version));
      }
    }
  }

  function readLibsFromHxml(path : String) : Array<{ name: String, version : Option<String> }> {
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
          Some(regex.matched(3));
        } catch (e : Dynamic) {
          None;
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
