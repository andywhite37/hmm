# Haxe Module Manager (`hmm`)

`hmm` is a small helper for `haxelib` that allows you to specify, install,
and update project dependencies using `lib.haxe.org` libraries, `git`,
`mercurial`, or `dev` (local path reference) libraries.

This exists because `haxelib` does not yet support specifying git, mercurial,
or other non `haxelib`-based project dependencies in the `haxelib.json`,
`.hxml`, etc. files. Once `haxelib` adds full git and hg support, this
project can probably go away.

`hmm` relies on the new `haxelib` local repo support, for installing project-local
Haxe libs in a `.haxelib` directory. See `haxelib newrepo` for more
details on this. It also uses `haxelib` itself for actually installing
libraries (both from lib.haxe.org and via git/hg/etc.).

# Installing hmm

```
> haxelib --global install hmm
> haxelib --global run hmm setup
```

- The `--global` flag is needed to make sure the tool is installed globally.
- The `setup` command creates aliases for ease of use:
  - on Linux/MacOS: creates a link to the `hmm` tool at `/usr/local/bin/hmm`
  - on Windows: creates a `hmm.cmd` script in `%HAXEPATH%`
- If you do not run `setup`, you can use the tool by running:

`haxelib --global run hmm [command] [options]`

rather than:

`hmm [command] [options]`

# Example workflows

### Installation

```sh
# Make sure hmm is installed (only needed once)
> haxelib --global install hmm
> haxelib --global run hmm setup
```

### Self-update (update the global hmm install)

```sh
> hmm hmm-update
```

### Self-removal (uninstall the global hmm install)

```sh
> hmm hmm-remove
```

### New project setup and dependency installation

```
# Create your project directory
> mkdir my-project
> cd my-project

# initialize hmm and local .haxelib (create hmm.json and empty .haxelib/ directory in my-project/
> hmm init

# install some libraries from lib.haxe.org
> hmm haxelib utest
> hmm haxelib chrome-extension 45.0.1

# install some libraries via git repos
> hmm git thx.core git@github.com:fponticelli/thx.core master src
> hmm git mithril https://github.com/ciscoheat/mithril-hx master mithril

# install some libraries via mercurial repos
> hmm hg orm https://bitbucket.org/yar3333/haxe-orm default library

# view the hmm.json
> cat hmm.json
{
  "dependencies": [
    {
      "name": "chrome-extension",
      "type": "haxelib",
      "version": "45.0.1"
    },
    {
      "name": "mithril",
      "type": "git",
      "dir": "mithril",
      "ref": "master",
      "url": "https://github.com/ciscoheat/mithril-hx"
    },
    {
      "name": "orm",
      "type": "hg",
      "dir": "library",
      "ref": "default",
      "url": "https://bitbucket.org/yar3333/haxe-orm"
    },
    {
      "name": "thx.core",
      "type": "git",
      "dir": "src",
      "ref": "master",
      "url": "git@github.com:fponticelli/thx.core"
    },
    {
      "name": "utest",
      "type": "haxelib",
      "version": ""
    }
  ]
}

# view the local haxelib installs
> haxelib list
chrome-extension: [45.0.1]
mithril: git [dev:/Users/awhite/temp/haxelib-test-3/.haxelib/mithril/git/mithril]
orm: hg [dev:/Users/awhite/temp/my-project/.haxelib/orm/hg/library]
thx.core: git [dev:/Users/awhite/temp/haxelib-test-3/.haxelib/thx,core/git/src]
utest: [1.3.10]
```

### Existing project setup if the project has an hmm.json file

```sh
# Clone a project that is using hmm
> git clone git@github.com:someuser/someproject
> cd someproject

# Install all libs from hmm.json
> hmm install
```

### Dependency updates/changes

```sh
# Update dependencies from hmm.json that are not already installed at the specified version
> hmm reinstall

# Update all dependencies in hmm.json, even if they are already installed at the right version
> hmm reinstall -f

# Update a few dependencies, but only if the current install of each does not match the specified version in hmm.json
> hmm reinstall mylib1 mylib2

# Update a few dependencies, even if the current install of each matches the specified version in hmm.json
> hmm reinstall --force mylib1 mylib2
```

# Project config file (hmm.json)

`hmm` requires a `hmm.json` file in the root of your project, which
specifies the project dependencies (similar to npm's package.json).

Example `hmm.json`:

```js
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
      // Note: while it works, it's considered a bad practice to reference a branch
      // - better to reference a tag, commit, or other non-changing reference
      // Use `hmm lock` to automatically save/update the current hash ref in hmm.json
      "dir": "src"
    },
    {
      "name": "svg2ppt",
      "type": "git",
      "url": "git@github.com:pellucidanalytics/svg2ppt",
      "ref": "ae94bdc",
      "dir": "src"
    },
    {
      "name": "mithril",
      "type": "haxelib"
      // Note: while this works, it's considered a bad practice to reference a library
      // without specifying the version
      // Use `hmm lock` to automatically save/update the current havelib version in hmm.json
    },
    {
      // Note: "dev" dependencies are allowed for convenience, but not considered ideal,
      // because they do not specify any versioning, and requires others to have the
      // same local directory
      "name": "mylib",
      "type": "dev",
      "path": "/my/path/mylib"
    }
  ]
}
```

Each dependency is an object with the following keys:

- `name` - (required) the name of the Haxe library
- `type` - (required) one of `haxelib`, `git`, `hg`, or `dev`

For `type` `haxelib`, the following additional properties are used:

- `version` - (optional) the haxelib library version

For `type` `git` or `mercurial`, the following additional properties are used:

- `url` - (required) the git/hg URL
- `ref` - (optional) the git/hg ref (branch, commit, tag, etc.)
- `dir` - (optional) the root classpath directory

For `type` `dev`, the following additional properties are used:

- `path` - (required) the file system path to the code

# Commands

- Almost all `hmm` commands should be run from your project root
  directory (where the `hmm.json` file should be located).
- See `hmm help` for information about specific commands.

# Development Info

Build the code:

```sh
> haxe build.hxml
```

Release new version:

```sh
> git tag -a 3.4.5 -m 'Some message'
> $EDITOR haxelib.json # Set version
> submit
```
