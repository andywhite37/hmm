package hmm;

import haxe.Json;
import haxe.io.Path;
import hmm.utils.Shell;
import hmm.utils.Log;
import sys.FileSystem;
import sys.io.File;
using Lambda;

typedef HmmConfigFile = {
  dependencies: Array<LibraryConfig>
};

class HmmConfig {
  public static var HMM_JSON_FILE_NAME = "hmm.json";
  public static var HAXELIB_REPO_DIR_NAME = ".haxelib";

  public static function getHmmJsonPath() {
    return Path.join([Shell.workingDirectory, HMM_JSON_FILE_NAME]);
  }

  public static function getLocalHaxelibRepoPath() {
    return Path.join([Shell.workingDirectory, HAXELIB_REPO_DIR_NAME]);
  }

  public static function hasHmmJson(){
    return FileSystem.exists(getHmmJsonPath());
  }

  public static function hasLocalHaxelibRepo() {
    return FileSystem.isDirectory(getLocalHaxelibRepoPath());
  }

  public static function getVersion() : String {
    var path = Path.join([Shell.hmmDirectory, "haxelib.json"]);
    var content = File.getContent(path);
    var data = Json.parse(content);
    return data.version;
  }

  public static function readHmmJson() : HmmConfigFile {
    var path = getHmmJsonPath();
    var text = File.getContent(path);
    return cast Json.parse(text);
  }

  public static function writeHmmJson(hmmConfigFile : HmmConfigFile) : Void {
    var path = getHmmJsonPath();
    var content = Json.stringify(hmmConfigFile, null, '  ');
    File.saveContent(path, content);
  }

  public static function addGitDependency(name : String, url : String, ref : String, dir : String) {
    addDependency({
      name: name,
      type: LibraryType.Git,
      url: url,
      ref: ref,
      dir: dir
    });
  }

  public static function addHgDependency(name : String, url : String, ref : String, dir : String) {
    addDependency({
      name: name,
      type: LibraryType.Mercurial,
      url: url,
      ref: ref,
      dir: dir
    });
  }

  public static function addHaxelibDependency(name : String, version : String) {
    addDependency({
      name: name,
      type: LibraryType.Haxelib,
      version: version
    });
  }

  public static function addDependency(lib : LibraryConfig) {
    Log.info('Adding dependency to ${getHmmJsonPath()}:');

    Log.debug('name: ${lib.name}');
    Log.debug('type: ${lib.type}');

    if (lib.version != null) Log.debug('version: ${lib.version}');
    if (lib.url != null) Log.debug('url: ${lib.url}');
    if (lib.ref != null) Log.debug('ref: ${lib.ref}');
    if (lib.dir != null) Log.debug('dir: ${lib.dir}');

    var hmmConfigFile = readHmmJson();

    // remove any libraries with the same name as the one we're adding
    hmmConfigFile.dependencies = hmmConfigFile.dependencies.filter(function(dep) {
      return dep.name != lib.name;
    });

    // add the new library
    hmmConfigFile.dependencies.push(lib);

    hmmConfigFile.dependencies.sort(function(a, b) {
      return if (a.name < b.name) -1;
        else if (a.name > b.name) 1;
        else 0;
    });

    writeHmmJson(hmmConfigFile);
  }

  public static function removeDependency(name : String) {
    Log.info('Removing dependency from ${getHmmJsonPath()}:');

    Log.debug('name: $name');

    var hmmConfigFile = readHmmJson();

    // remove any libraries with the same name as the one we're adding
    hmmConfigFile.dependencies = hmmConfigFile.dependencies.filter(function(dep) {
      return dep.name != name;
    });

    hmmConfigFile.dependencies.sort(function(a, b) {
      return if (a.name < b.name) -1;
        else if (a.name > b.name) 1;
        else 0;
    });

    writeHmmJson(hmmConfigFile);
  }
}
