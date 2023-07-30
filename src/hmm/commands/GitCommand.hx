package hmm.commands;

using StringTools;

import haxe.ds.Option;
import sys.FileSystem;
import sys.io.File;

using thx.Functions;
using thx.Options;

import hmm.HmmConfig;
import hmm.LibraryConfig;
import hmm.errors.ValidationError;
import hmm.utils.Shell;
import hmm.utils.Log;

class GitCommand implements ICommand {
  public var type(default, null) = "git";

  public static var DEFAULT_REF = "master";

  public function new() {}

  public function run(args:Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();

    if (args.length < 2 || args.length > 4) {
      throw new ValidationError('$type command requires 2, 3, or 4 arguments (<name> <url> [ref] [dir])', 1);
    }

    var name:String = args[0];
    var url:String = args[1];
    var ref:Option<String> = Some(DEFAULT_REF);
    var dir:Option<String> = None;

    if (args.length >= 3) {
      ref = Options.ofValue(args[2]).filter(a -> a.trim() != "");
    }

    if (args.length == 4) {
      dir = Options.ofValue(args[3]).filter(a -> a.trim() != "");
    }

    // Add the library to the hmm.json
    HmmConfigs.addDependencyOrThrow(Git(name, url, ref, dir));

    // Install the library
    Shell.haxelibGit(name, url, ref, dir, {log: true, throwError: true});

    // Show the resulting haxelib list
    Shell.haxelibList({log: true, throwError: true});
  }

  public function getUsage() {
    return 'adds a git-based dependency to hmm.json, and installs the dependency using `haxelib git`

        usage: hmm git <name> <url> [ref] [dir]

        arguments:
        - name - the name of the library (required)
        - url - the clone url or path to the git repo (required)
        - ref - the branch name/tag name/committish to use when installing/updating the library (default: "$DEFAULT_REF")
        - dir - the sub-directory in the git repo where the code is located (optional)

        ref and sub-directory are optional, however, to specify sub-directory, you must also specify the ref.

        example:

        hmm git thx.core git@github.com:fponticelli/thx.core
        - assumes ref is "master" and sub-directory is the root of the repo

        hmm git thx.core git@github.com:fponticelli/thx.core some-tag src
        - assumes ref is "some-tag" and sub-directory is "src"
';

  }
}
