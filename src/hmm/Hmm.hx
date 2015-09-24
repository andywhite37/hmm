package hmm;

import mcli.CommandLine;
import mcli.Dispatch;
import hmm.commands.*;

class Hmm extends CommandLine {
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
    No-op
  **/
  public function runDefault() {
  }

  public static function main() {
    new Dispatch(Sys.args()).dispatch(new Hmm());
  }
}

