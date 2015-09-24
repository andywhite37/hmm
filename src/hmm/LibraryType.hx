package hmm;

@:enum
abstract LibraryType(String) to String {
  var Haxelib = "haxelib";
  var Git = "git";
  var Mercurial = "hg";

  @:from
  public static function fromString(input : String) : LibraryType {
    return switch input {
      case "haxelib": Haxelib;
      case "git": Git;
      case "hg" | "mercurial": Mercurial;
      case _: throw 'Unknown library type $input';
    };
  }
}
