package hmm.commands;

import hmm.utils.Log;

class HelpCommand implements ICommand {
  public var type(default, null) = "help";

  public function new() {
  }

  public function run(args : Array<String>) {
    if (args.length == 0) {
      Hmm.printUsageAndExit(0);
    } else {
      Hmm.printUsagesAndExit(args, 0);
    }
  }

  public function getUsage() {
    return 'shows a usage message

        usage:

        hmm help [names]

        arguments:
        - (optional) [names] - zero or more command names

        examples:

        hmm help
        hmm help clean
        hmm help clean check
';
  }
}
