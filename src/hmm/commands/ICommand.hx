package hmm.commands;

import thx.Nil;
import thx.Validation;

interface ICommand {
  public var type(default, null) : String;

  public function run(args : Array<String>) : Void;

  public function getUsage() : String;
}
