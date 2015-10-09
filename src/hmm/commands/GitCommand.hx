package hmm.commands;

import hmm.utils.Shell;
import hmm.utils.Log;
import sys.FileSystem;
import sys.io.File;

class GitCommand implements ICommand {
  public var type(default, null) = "git";

  public static var DEFAULT_REF = "master";
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

    HmmConfig.addGitDependency(name, url, ref, dir);
    Shell.haxelibGit(name, url, ref, dir);
    Shell.haxelibList();
  }

  public function getUsage() {
    return 'adds a git-based dependency to hmm.json, and installs the dependency using `haxelib git`

        usage: hmm git <name> <url> [ref] [dir]

        arguments:
        - name - the name of the library (required)
        - url - the clone url or path to the git repo (required)
        - ref - the branch name/tag name/committish to use when installing/updating the library (default: "$DEFAULT_REF")
        - dir - the sub-directory in the git repo where the code is located (default: "$DEFAULT_DIR")

        ref and sub-directory are optional, however, to specify sub-directory, you must also specify the ref.

        example:

        hmm git thx.core git@github.com:fponticelli/thx.core
        - assumes ref is "master" and sub-directory is the root of the repo

        hmm git thx.core git@github.com:fponticelli/thx.core some-tag src
        - assumes ref is "some-tag" and sub-directory is "src"
';
  }
}

