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

class HgCommand implements ICommand {
  public var type(default, null) = "hg";

  public static var DEFAULT_REF = "default";

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

    HmmConfigs.addDependencyOrThrow(Mercurial(name, url, ref, dir));
    Shell.haxelibHg(name, url, ref, dir, {log: true, throwError: true});
    Shell.haxelibList({log: true, throwError: true});
  }

  public function getUsage() {
    return 'adds a hg-based dependency to hmm.json, and installs the dependency using `haxelib hg`

        usage: hmm hg <name> <url> [ref] [dir]

        arguments:
        - name - the name of the library (required)
        - url - the clone url or path to the hg repo (required)
        - ref - the branch name/tag name/committish to use when installing/updating the library (default: "$DEFAULT_REF")
        - dir - the sub-directory in the hg repo where the code is located (default: "")

        ref and sub-directory are optional, however, to specify sub-directory, you must also specify the ref.

        example:

        hmm hg orm https://bitbucket.org/yar3333/haxe-orm default library
        - install "orm" from bitbucket at branch "default" with sub-directory "library"
';

  }
}
