package hmm.commands;

using StringTools;

import haxe.ds.Option;
import sys.FileSystem;

import thx.Nil;
import thx.Validation;

import hmm.HmmConfig;
import hmm.LibraryConfig;
import hmm.errors.ValidationError;
import hmm.utils.Shell;
import hmm.utils.Log;

class LockVersionCommand implements ICommand {
  public var type(default, null) = "lock";

  public function new() {
  }

  public function run(args : Array<String>) : Void {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();
    var config = HmmConfigs.readHmmJsonOrThrow();

    var libs = config.dependencies;
    if (args.length > 0) {
      libs = libs.filter(function (lib) return args.indexOf(LibraryConfigs.getName(lib)) >= 0);
    }

    var checks = 0;
    var successes : Array<LibraryConfig> = [];
    for (library in libs) {
      checks++;
      if (switch library {
        case Haxelib(name, version) : lockHaxelibVersion(name, version);
        case Git(name, url, ref, dir) : lockGitVersion(name, url, ref, dir);
        case Mercurial(name, url, ref, dir) : lockHgVersion(name, url, ref, dir);
        case Dev(name, path) : false;
      }) successes.push(library);
    }

    var versionText = successes.length == 1 
      ? "library version has been updated" 
      : "library versions have been updated";
    Log.info('${successes.length} out of $checks $versionText');
  }

  public function getUsage() {
    return 'update libraries versions or refs in hmm.json.
    
        usage: hmm lock [<lib1> [... <libn>]]

        arguments: zero or more library names

        - haxelib library: the current version is written
        - git/hg library: the current hash ref is written
        - dev library: nothing happens

        example:

        hmm lock
        - locks all libraries

        hmm lock thx.core
        hmm lock thx.core mithril
        - locks specific libraries only
';
  }

  function lockHgVersion(name : String, url : String, ref : Option<String>, dir : Option<String>) {
    if (!FileSystem.exists('.haxelib/$name/hg/.hg')) throw new ValidationError('Library $name is not checked out', 1);

    var cwd = Sys.getCwd();
    Sys.setCwd('.haxelib/$name/hg');
    var result = Shell.readCommand("hg", ["id", "-i"], { log: false, throwError: true });
    Sys.setCwd(cwd);

    var newRef = StringTools.trim(result.stdout);
    if (!~/^[a-z0-9]+$/i.match(newRef)) throw new ValidationError('Library $name has no ref', 1);
    if (newRef.endsWith("+")) newRef = newRef.substr(0, newRef.length - 1); // changes marker
    
    if (switch ref {
      case None: true;
      case Some(currentRef): currentRef != newRef;
    }) {
      Log.info('Lock $name to ref ${newRef}');
      HmmConfigs.addDependencyOrThrow(Git(name, url, Some(newRef), dir), true);
      return true;
    }
    return false;
  }

  function lockGitVersion(name : String, url : String, ref : Option<String>, dir : Option<String>) {
    if (!FileSystem.exists('.haxelib/$name/git/.git')) throw new ValidationError('Library $name is not checked out', 1);

    var cwd = Sys.getCwd();
    Sys.setCwd('.haxelib/$name/git');
    var result = Shell.readCommand("git", ["rev-parse", "--short", "HEAD"], { log: false, throwError: true });
    Sys.setCwd(cwd);

    var newRef = result.stdout.trim();
    if (!~/^[a-z0-9]+$/i.match(newRef)) throw new ValidationError('Library $name has no ref', 1);
    
    if (switch ref {
      case None: true;
      case Some(currentRef): currentRef != newRef;
    }) {
      Log.info('Lock $name to ref ${newRef}');
      HmmConfigs.addDependencyOrThrow(Git(name, url, Some(newRef), dir), true);
      return true;
    }
    return false;
  }

  function lockHaxelibVersion(name : String, version: Option<String>) {
      var result = Shell.haxelibPath(name, { log: false, throwError: false });
      if (!result.isInstalled) throw new ValidationError('Library $name is not installed', 1);
      var newVersion = result.version;
      
      if (switch version {
        case None: true;
        case Some(currentVersion): currentVersion != newVersion;
      }) {
        Log.info('Lock $name to version ${newVersion}');
        HmmConfigs.addDependencyOrThrow(Haxelib(name, Some(newVersion)), true);
        return true;
      }
      return false;
  }
}
