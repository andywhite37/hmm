package hmm;

using StringTools;

import haxe.ds.Option;

import thx.Either;
using thx.Functions;
import thx.Functions.*;
using thx.Options;
import thx.Validation;
import thx.Validation.*;
import thx.fp.Dynamics.*;

/**
  Metadata that describes a Haxe library installation source
**/
enum LibraryConfig {
  Haxelib(name : String, version: Option<String>);
  Git(name : String, url: String, ref: Option<String>, dir: Option<String>);
  Mercurial(name : String, url: String, ref: Option<String>, dir: Option<String>);
}

class LibraryConfigs {
  static inline var HAXELIB_TYPE = "haxelib";
  static inline var GIT_TYPE = "git";
  static inline var MERCURIAL_TYPE = "hg";

  public static function getName(lib : LibraryConfig) : String {
    return switch lib {
      case Haxelib(name, _) : name;
      case Git(name, _, _, _) : name;
      case Mercurial(name, _, _, _) : name;
    };
  }

  public static function isSameName(a : LibraryConfig, b : LibraryConfig) : Bool {
    return getName(a) == getName(b);
  }

  public static function compareByName(a : LibraryConfig, b : LibraryConfig) : Int {
    return thx.Strings.compare(getName(a), getName(b));
  }

  public static function deserialize(v : Dynamic) : VNel<String, LibraryConfig> {
    return thx.fp.Dynamics.parseProperty(v, "type", parseString, identity)
      .flatMapV(function(type : String) : VNel<String, LibraryConfig> {
        return switch type.toLowerCase() {
          case HAXELIB_TYPE : deserializeHaxelib(v);
          case GIT_TYPE : deserializeGit(v);
          case MERCURIAL_TYPE | "mercurial" : deserializeMercurial(v);
          case unk : failureNel('unrecognized library type: $unk');
        };
      });
  }

  public static function serialize(v : LibraryConfig) : {} {
    return switch v {
      case Haxelib(name, version) : { type: HAXELIB_TYPE, name: name, version: version.get() };
      case Git(name, url, ref, dir) : { type: GIT_TYPE, name: name, url: url, ref: ref.get(), dir: dir.get() };
      case Mercurial(name, url, ref, dir) : { type: MERCURIAL_TYPE, name: name, url: url, ref: ref.get(), dir: dir.get() };
    };
  }

  static function deserializeHaxelib(v : Dynamic) : VNel<String, LibraryConfig> {
    return val2(
      Haxelib,
      parseProperty(v, "name", parseString, identity),
      parseOptionalStringProperty(v, "version"),
      thx.Nel.semigroup()
    );
  }

  static function deserializeGit(v : Dynamic) : VNel<String, LibraryConfig> {
    return val4(
      Git,
      parseProperty(v, "name", parseString, identity),
      parseProperty(v, "url", parseString, identity),
      parseOptionalStringProperty(v, "ref"),
      parseOptionalStringProperty(v, "dir"),
      thx.Nel.semigroup()
    );
  }

  static function deserializeMercurial(v : Dynamic) : VNel<String, LibraryConfig> {
    return val4(
      Mercurial,
      parseProperty(v, "name", parseString, identity),
      parseProperty(v, "url", parseString, identity),
      parseOptionalProperty(v, "ref", parseString),
      parseOptionalProperty(v, "dir", parseString),
      thx.Nel.semigroup()
    );
  }

  static function parseOptionalStringProperty(v : {}, name : String) : VNel<String, Option<String>> {
    return parseOptionalProperty(v, name, parseString).map(function(str : Option<String>) : Option<String> {
      return str.filter.fn(_.trim() != "");
    });
  }
}
