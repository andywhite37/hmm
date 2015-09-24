package hmm;

import mcli.CommandLine;
import mcli.Dispatch;

class Hmm extends CommandLine {

  /**
    Enables verbose logging
    @alias v
  **/
  public var verbose : Bool;

  public static function main() {
    new Dispatch(Sys.args()).dispatch(new Hmm());
  }

  /**
    Prints the help information for hmm
  **/
  public function help() {
    Sys.println(showUsage());
    Sys.exit(1);
  }

  /**
    Installs haxe libs
  **/
  public function install(d : Dispatch) {
    d.dispatch(new InstallCommand());
  }

  /**
    Updates haxe libs
  **/
  public function update(d : Dispatch) {
    d.dispatch(new UpdateCommand());
  }

  /**
    Removes local .haxelib repo directory
  **/
  public function clean(d : Dispatch) {
    d.dispatch(new CleanCommand());
  }

  /**
    Shows the version of hmm
  **/
  public function version(d : Dispatch) {
  }

  public function runDefault() {
  }
}

