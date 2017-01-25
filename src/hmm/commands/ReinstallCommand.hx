package hmm.commands;

import haxe.ds.Option;

import sys.FileSystem;
import sys.io.File;

using thx.Arrays;
using thx.Functions;
using thx.Options;

import hmm.HmmConfig;
import hmm.LibraryConfig;
import hmm.errors.ValidationError;
import hmm.utils.Args;
import hmm.utils.Arrays;
import hmm.utils.Log;
import hmm.utils.Shell;

class ReinstallCommand implements ICommand {
  public var type(default, null) = "reinstall";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();

    var config = HmmConfigs.readHmmJsonOrThrow();
    var hmmNames = config.dependencies.map(LibraryConfigs.getName);

    var force = Args.hasAny(args, ["-f", "--force"]);
    var names = Args.removeAll(args, ["-f", "--force"]);

    var invalidNames : Array<String> = [];
    for (name in names) {
      if (!hmmNames.contains(name)) {
        invalidNames.push(name);
      }
    }
    if (invalidNames.length == 1) {
      throw new ValidationError('invalid library: ${invalidNames[0]} - not specified in hmm.json', 1);
    } else if (invalidNames.length > 1) {
      throw new ValidationError('invalid libraries: ${invalidNames.join(", ")} - not specified in hmm.json', 1);
    }

    var libs = if (names.length == 0) {
      config.dependencies;
    } else {
      config.dependencies.filter(function(lib) {
        return Arrays.contains(names, LibraryConfigs.getName(lib));
      });
    }

    for (lib in libs) {
      reinstall(lib, force);
    }

    Shell.haxelibList({ log: true, throwError: true });
  }

  function reinstall(library : LibraryConfig, force : Bool) : Void {
    return switch library {
      case Haxelib(name, version): reinstallHaxelib(name, version, force);
      case Git(name, url, ref, dir): reinstallGit(name, url, ref, dir, force);
      case Mercurial(name, url, ref, dir): reinstallMercurial(name, url, ref, dir, force);
      case Dev(name, path) : reinstallDev(name, path, force);
    };
  }

  function reinstallHaxelib(name : String, version : Option<String>, force : Bool) {
    if (force || !Shell.isAlreadyInstalledHaxelib(name, version, { log: false, throwError: true })) {
      Log.info('reinstalling haxelib library: $name at version $version');
      Shell.haxelibRemove(name, { log: true, throwError: false });
      Shell.haxelibInstall(name, version, { log: true, throwError: false });
    } else {
      Log.info('haxelib library "$name" (version: ${version.getOrElse('N/A')}) already installed');
    }
  }

  function reinstallGit(name : String, url : String, ref : Option<String>, dir : Option<String>, force: Bool) {
    if (force || !Shell.isAlreadyInstalledGit(name, url, ref, dir, { log: false, throwError: true })) {
      Log.info('reinstalling git library: $name from $url (ref: $ref, dir: $dir)');
      Shell.haxelibRemove(name, { log: true, throwError: false });
      Shell.haxelibGit(name, url, ref, dir, { log: true, throwError: true });
    } else {
      Log.info('git library "$name" (url: $url, ref: ${ref.getOrElse('N/A')}, dir: ${dir.getOrElse("N/A")}) already installed');
    }
  }

  function reinstallMercurial(name : String, url : String, ref : Option<String>, dir : Option<String>, force: Bool) {
    if (force || !Shell.isAlreadyInstalledMercurial(name, url, ref, dir, { log: false, throwError: true })) {
      Log.info('reinstalling hg library: $name from $url (ref: $ref, dir: $dir)');
      Shell.haxelibRemove(name, { log: true, throwError: false });
      Shell.haxelibHg(name, url, ref, dir, { log: true, throwError: true });
    } else {
      Log.info('hg library "$name" (url: $url, ref: ${ref.getOrElse('N/A')}, dir: ${dir.getOrElse("N/A")}) already installed');
    }
  }

  function reinstallDev(name : String, path : String, force: Bool) : Void {
    if (force || !Shell.isAlreadyInstalledDev(name, path, { log: false, throwError: true })) {
      Log.info('reinstalling dev library: $name (path: $path)');
      Shell.haxelibRemove(name, { log: true, throwError: false });
      Shell.haxelibDev(name, path, { log: true, throwError: true });
    } else {
      Log.info('dev library "$name" (path: $path) already installed');
    }
  }

  public function getUsage() {
    return 'reinstalls libraries listed in hmm.json

        usage: hmm reinstall [-f|--force] [names]

        options:
        - (optional) -f or --force - remove the library before reinstalling it

        arguments:
        - (optional) names - one or more space-separated library names to reinstall

        example:

        hmm reinstall
        - for each library in hmm.json:
          - gets the currently-installed version/ref
          - gets the version/ref listed in hmm.json
          - if the versions/refs match, do nothing
          - if the versions/refs don\'t match, remove the lib and re-install it at the version listed in hmm.json

        hmm reinstall -f my-lib my-other-lib
        - removes my-lib and my-other-lib and installs them at the versions/refs listed in hmm.json
';
  }
}

