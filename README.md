# Haxe Module Manager (`hmm`)

`hmm` is a small helper for `haxelib` that allows you to specify, install,
and update project dependencies using lib.haxe.org libraries, git, or
mercurial repositories.

This exists because `haxelib` does not yet support specifying git, mercurial,
or other non `haxelib`-based project dependencies in the `haxelib.json`,
`.hxml`, etc. files.  Once `haxelib` adds full git and hg support, this
project can probably go away.

`hmm` relies on the new `haxelib` local repo support, for installing project-local
Haxe libs in a `.haxelib` directory.  See `haxelib newrepo` for more
details on this.  It also uses `haxelib` itself for actually installing
libraries (both from lib.haxe.org and via git/hg/etc.).

# Installing hmm

```
> haxelib --global install hmm
> haxelib --global run hmm setup
```

- The `--global` flag is needed to make sure the tool is installed globally.
- The `setup` command creates a link to the `hmm` tool at `/usr/local/bin/hmm` for ease of use.
- If you do not run `setup`, you can use the tool by running:

`haxelib --global run hmm [command] [options]`

rather than:

`hmm [command] [options]`

# hmm config file (hmm.json)

`hmm` requires a `hmm.json` file in the root of your project, which
specifies the project dependencies (similar to npm's package.json).

Example `hmm.json`:

```json
{
  "dependencies": [
    {
      "name": "thx.core",
      "type": "haxelib",
      "version": "0.34.0"
    },
    {
      "name": "thx.promise",
      "type": "git",
      "url": "git@github.com:fponticelli/thx.promise",
      "ref": "master",
      "dir": "src"
    },
    {
      "name": "svg2ppt",
      "type": "git",
      "url": "git@github-pellucid:pellucidanalytics/svg2ppt",
      "ref": "master",
      "dir": "src"
    },
    {
      "name": "mithril",
      "type": "haxelib"
    }
  ]
}
```

Each dependency is an object with the following keys:

- `name` - the name of the Haxe library
- `type` - one of `haxelib`, `git`, or `hg`
- `version` - the haxelib library version (for `haxelib` libs)
- `url` - the git/hg URL (for `git` or `hg` libs)
- `ref` - the git/hg ref (branch, commit, tag, etc.) (for `git` and `hg`
  installs)
- `dir` - the root classpath directory (for `git` and `hg` installs)

# hmm commands

- Almost all `hmm` commands should be run from your project root
  directory (where the `hmm.json` file should be located).
- See `hmm help` for information about specific commands.

`> hmm help`

```sh
Usage: hmm <command> [options]

commands:

    help - shows a usage message

    version - print hmm version

    setup - creates a symbolic link to hmm at /usr/local/bin/hmm

    init - initializes the current working directory for hmm usage

    install - installs libraries listed in hmm.json

    haxelib - adds a lib.haxe.org-based dependency to hmm.json, and installs the dependency using `haxelib install`

        usage: hmm haxelib <name> [version]

        arguments:
        - name - the name of the library (required)
        - version - the version to install (default: "")

        example:

        hmm haxelib thx.core
        - adds and installs the current version of thx.core (no version specified)

        hmm haxelib thx.core 1.2.3
        - adds and installs thx.core version 1.2.3

    git - adds a git-based dependency to hmm.json, and installs the dependency using `haxelib git`

        usage: hmm git <name> <url> [ref] [dir]

        arguments:
        - name - the name of the library (required)
        - url - the clone url or path to the git repo (required)
        - ref - the branch name/tag name/committish to use when installing/updating the library (default: "master")
        - dir - the sub-directory in the git repo where the code is located (default: "")

        ref and sub-directory are optional, however, to specify sub-directory, you must also specify the ref.

        example:

        hmm git thx.core git@github.com:fponticelli/thx.core
        - assumes ref is "master" and sub-directory is the root of the repo

        hmm git thx.core git@github.com:fponticelli/thx.core some-tag src
        - assumes ref is "some-tag" and sub-directory is "src"


    update - updates libraries listed in hmm.json

    remove - removes one or more library dependencies from hmm.json, and removes them via `haxelib remove`

        usage: hmm remove <name> [name2 name3 ...]

        arguments:
        - name - the name of the library to remove (required)
        - name2 name3 ... - additional library names to remove

        example:

        hmm remove thx.core
        hmm remove thx.core mithril


    clean - removes local .haxelib directory

    hmm-update - updates the hmm tool
```
