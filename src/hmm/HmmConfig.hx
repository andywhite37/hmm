package hmm;

import haxe.Json;
import haxe.ds.Option;
import haxe.io.Path;

// import sys.FileSystem;
// import sys.io.File;
using thx.Arrays;

import thx.Either;

using thx.Functions;

import thx.Functions.*;
import thx.Validation;
import thx.Validation.*;
import hmm.LibraryConfig;
import hmm.utils.Dynamics.*;
import hmm.utils.Shell;
import hmm.utils.Log;

typedef HmmConfig = {
  dependencies:Array<LibraryConfig>
};

class HmmConfigs {
  public static var HMM_JSON_FILE_NAME = "hmm.json";
  public static var HAXELIB_REPO_DIR_NAME = ".haxelib";

  public static function getHmmJsonPath():String {
    return Path.join([Shell.workingDirectory, HMM_JSON_FILE_NAME]);
  }

  public static function getLocalHaxelibRepoPath():String {
    return Path.join([Shell.workingDirectory, HAXELIB_REPO_DIR_NAME]);
  }

  public static function hasHmmJson():Bool {
    return sys.FileSystem.exists(getHmmJsonPath());
  }

  public static function hasLocalHaxelibRepo():Bool {
    var path = getLocalHaxelibRepoPath();
    return sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path);
  }

  public static function getVersion():String {
    var path = Path.join([Shell.hmmDirectory, "haxelib.json"]);
    var content = sys.io.File.getContent(path);
    var data = Json.parse(content);
    return data.version;
  }

  public static function readHmmJson():VNel<String, HmmConfig> {
    return try {
      var path = getHmmJsonPath();
      var text = sys.io.File.getContent(path);
      var data:Dynamic = Json.parse(text);
      deserialize(data);
    } catch (e:Dynamic) {
      var error = thx.Error.fromDynamic(e);
      failureNel(error.message);
    }
  }

  public static function readHmmJsonOrThrow():HmmConfig {
    return switch readHmmJson().either {
      case Left(errs): throw new thx.Error(errs.toArray().join(", "));
      case Right(hmmConfig): hmmConfig;
    };
  }

  static function writeHmmJson(hmmConfigFile:HmmConfig):VNel<String, HmmConfig> {
    return try {
      var path = getHmmJsonPath();
      var raw:{} = serialize(hmmConfigFile);
      var content = Json.stringify(raw, null, '  ');
      sys.io.File.saveContent(path, content);
      readHmmJson();
    } catch (e:Dynamic) {
      var error = thx.Error.fromDynamic(e);
      failureNel(error.message);
    }
  }

  public static function deserialize(data:Dynamic):VNel<String, HmmConfig> {
    return parseProperty(data, "dependencies", parseArray.bind(_, LibraryConfigs.deserialize, identity), identity).map(a -> {dependencies: a});
  }

  public static function serialize(hmmConfigFile:HmmConfig):{} {
    return {
      dependencies: hmmConfigFile.dependencies.order(LibraryConfigs.compareByName).map(LibraryConfigs.serialize)
    };
  }

  public static function addDependency(lib:LibraryConfig, silent = false):VNel<String, HmmConfig> {
    if (!silent) {
      Log.info('Adding library: "${LibraryConfigs.getName(lib)}" to: ${getHmmJsonPath()}:');
    }
    return readHmmJson().map(function(hmmConfigFile:HmmConfig):HmmConfig {
      // Remove any existing libraries with the same name as the one we are going to add
      return {
        dependencies: hmmConfigFile.dependencies.filter(function(existingLib) {
          return !LibraryConfigs.isSameName(existingLib, lib);
        })
      };
    }).map(function(hmmConfigFile:HmmConfig):HmmConfig {
      // Add the library
      return {
        dependencies: hmmConfigFile.dependencies.append(lib)
      };
    }).flatMapV(function(hmmConfigFile:HmmConfig):VNel<String, HmmConfig> {
      // Save the hmm.json
      return writeHmmJson(hmmConfigFile);
    });
  }

  public static function addDependencyOrThrow(lib:LibraryConfig, silent = false):HmmConfig {
    return switch addDependency(lib, silent).either {
      case Left(errs): throw new thx.Error(errs.toArray().join(", "));
      case Right(hmmConfig): hmmConfig;
    };
  }

  public static function removeDependency(name:String):VNel<String, HmmConfig> {
    Log.info('Removing library: "$name" from: ${getHmmJsonPath()}:');
    return readHmmJson().map(function(hmmConfigFile:HmmConfig):HmmConfig {
      return {
        dependencies: hmmConfigFile.dependencies.filter(function(existingLib) {
          return LibraryConfigs.getName(existingLib) != name;
        })
      };
    }).flatMapV(function(hmmConfigFile:HmmConfig):VNel<String, HmmConfig> {
      return writeHmmJson(hmmConfigFile);
    });
  }

  public static function removeDependencyOrThrow(name:String):HmmConfig {
    return switch removeDependency(name).either {
      case Left(errs): throw new thx.Error(errs.toArray().join(", "));
      case Right(hmmConfig): hmmConfig;
    };
  }
}
