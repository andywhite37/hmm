package hmm.commands;

import hmm.utils.Shell;
import hmm.utils.Log;
using StringTools;

class CheckCommand implements ICommand {
  public var type(default, null) = "check";

  public function new() {
  }

  public function run(args : Array<String>) {
    Shell.ensureHmmJsonExists();
    Shell.createLocalHaxelibRepoIfNotExists();

    var config = HmmConfig.readHmmJson();

    var failures = 0;
    for (library in config.dependencies) {
      failures += checkLibrary(library) ? 0 : 1;
    }

    if (failures > 0) {
      var librariesText = failures == 1 ? "library is" : "libraries are";
      var hasText = failures == 1 ? "has" : "have";
      Log.die('$failures $librariesText not installed, or $hasText the wrong version.
Use `hmm update` or `hmm clean && hmm install` to attempt to fix.');
    }
  }

  function checkLibrary(library : LibraryConfig) : Bool {
    var haxelibPath = HmmConfig.getLocalHaxelibRepoPath();

    return switch library.type {
      case Haxelib: checkHaxelibLibrary(library, haxelibPath);
      case Git: checkGitLibrary(library, haxelibPath);
      case Mercurial: checkHgLibrary(library, haxelibPath);
    };
  }

  function checkHaxelibLibrary(library : LibraryConfig, haxelibPath : String) : Bool {
    var pathInfo = Shell.haxelibPath(library.name);
    return if (!pathInfo.isInstalled) {
      Log.warning('${library.name} is not installed');
      false;
    } else if (library.version != null && library.version != "") {
      // version is specified
      if (library.version != pathInfo.version) {
        Log.warning('${library.name} is installed at version: ${pathInfo.version}, which does not match specified version: ${library.version}');
        false;
      } else {
        Log.info('${library.name} is installed at version: ${pathInfo.version}, which matches specified version: ${library.version}');
        true;
      }
    } else {
      // version is not specified in hmm.json, so any installation is fine
      Log.info('${library.name} is installed (no version specified)');
      true;
    }
  }

  function checkGitLibrary(library : LibraryConfig, haxelibPath) : Bool {
    var pathInfo = Shell.haxelibPath(library.name);
    return if (!pathInfo.isInstalled) {
      Log.warning('${library.name} is not installed');
      false;
    } else if (library.ref != null && library.ref != "") {
      // version is specified
      var actualCommit = Shell.gitRevParse(pathInfo.path, "HEAD");
      var specifiedCommit = Shell.gitRevParse(pathInfo.path, library.ref);
      var actualCommitDisplay = actualCommit.substr(0, 8);
      var specifiedCommitDisplay = specifiedCommit.substr(0, 8);

      if (isSameCommit(actualCommit, specifiedCommit)) {
        Log.info('${library.name} is installed at commit: $actualCommitDisplay, which matches specified ref: ${library.ref} ($specifiedCommitDisplay)');
        true;
      } else {
        Log.warning('${library.name} is installed at commit: $actualCommitDisplay, which does not match the specified ref ${library.ref} ($specifiedCommitDisplay)');
        false;
      }
    } else {
      // version is not specified in hmm.json, so any installation is fine
      Log.info('${library.name} is installed (no version specified in hmm.json)');
      true;
    }
  }

  function checkHgLibrary(library : LibraryConfig, haxelibPath) : Bool {
    Log.die('check command for Mercurial repos not yet implemented');
    return false;
  }

  function fixLibraryName(name : String) : String {
    return name.replace(".", ",");
  }

  function isSameCommit(a : String, b : String) {
    if (a.length > b.length) {
      a = a.substr(0, b.length);
    } else if (b.length > a.length) {
      b = b.substr(0, a.length);
    }
    return a == b;
  }

  public function getUsage() {
    return "checks if the current .haxelib installations match the hmm.json-specified versions/refs/etc.";
  }
}
