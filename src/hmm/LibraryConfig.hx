package hmm;

/**
  Metadata that describes a Haxe library installation source
**/
typedef LibraryConfig = {
  type: LibraryType,
  name: String,
  ?version : String,
  ?url : String,
  ?ref : String,
  ?dir : String,
};
