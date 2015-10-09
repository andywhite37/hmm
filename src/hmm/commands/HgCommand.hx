package hmm.commands;

import hmm.utils.Shell;
import hmm.utils.Log;
import sys.FileSystem;
import sys.io.File;

class HgCommand implements ICommand {
  public var type(default, null) = "hg";

  public static var DEFAULT_REF = "default";
  public static var DEFAULT_DIR = "";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();

    if (args.length < 2 || args.length > 4) {
      Log.die('$type command requires 2, 3, or 4 arguments (<name> <url> [ref] [dir])');
    }

    var name = args[0];
    var url = args[1];
    var ref = DEFAULT_REF;
    var dir = DEFAULT_DIR;

    if (args.length >= 3) {
      ref = args[2];
    }

    if (args.length == 4) {
      dir = args[3];
    }

    HmmConfig.addHgDependency(name, url, ref, dir);
    Shell.haxelibHg(name, url, ref, dir);
    Shell.haxelibList();
  }

  public function getUsage() {
    return 'adds a hg-based dependency to hmm.json, and installs the dependency using `haxelib hg`

        usage: hmm hg <name> <url> [ref] [dir]

        arguments:
        - name - the name of the library (required)
        - url - the clone url or path to the hg repo (required)
        - ref - the branch name/tag name/committish to use when installing/updating the library (default: "$DEFAULT_REF")
        - dir - the sub-directory in the hg repo where the code is located (default: "$DEFAULT_DIR")

        ref and sub-directory are optional, however, to specify sub-directory, you must also specify the ref.

        example:

        hmm hg orm https://bitbucket.org/yar3333/haxe-orm default library
        - install "orm" from bitbucket at branch "default" with sub-directory "library"
';
  }
}

