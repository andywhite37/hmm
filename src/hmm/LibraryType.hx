package hmm;

/**
  The installation type for a library
**/
@:enum
abstract LibraryType(String) to String from String {
  var Haxelib = "haxelib";
  var Git = "git";
  var Mercurial = "hg";
}
