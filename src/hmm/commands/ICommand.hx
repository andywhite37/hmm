package hmm.commands;

interface ICommand {
  public var type(default, null) : String;

  public function run() : Void;

  public function getUsage() : String;
}
