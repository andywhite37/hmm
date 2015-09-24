# Haxe Module Manager (hmm)

hmm is a small helper for haxelib that allows you to specify, install,
and update project dependencies using haxelib libraries, git or
mercurial repositories.

This exists because haxelib does not yet support specifying git, mercurial,
or other non haxelib-based project dependencies in the haxelib.json,
.hxml, etc. files.  Once haxelib adds full git and hg support, this
project can go away.

hmm relies on the new "haxelib local repo" support, for installing project-local
haxelibs in a .haxelib directory.  See `haxelib newrepo` for more
details.

## Installing hmm

haxelib --global install hmm

> --global flag is needed to make sure the tool is installed globally,
> not in a local .haxelib repo for the project.

## Project config file (hmm.json)

hmm requires a `hmm.json` file in the root of your project, which
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

## Running hmm

- cd to your project root directory
- ensure the `hmm.json` file exists in the root with some dependencies listed like above

### Install all dependencies in `hmm.json`:

`haxelib --global run hmm install`

### Update all dependencies in `hmm.json`:

`haxelib --global run hmm update`

### Remove the local .haxelib directory:

`haxelib --global run hmm clean`

> `hmm` uses `haxelib` internally for doing installs and updates

## TODO

- Create a link/script to run from the $PATH rather than having to use `haxelib run hmm`
