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
    `haxelib run hmm [command] [options]` rather than `hmm [command] [options]`

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
