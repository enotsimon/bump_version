# bump_version

## overwiev

little task for Elixir Mix that updates your 'VERSION' file, and make commit, if its a git repository

thats for `mix release`


## install

add

`{:bump_version, git: "ssh://git@stash.sj-dev.local:7999/search/bump_version.git", branch: "master"}`

to your `mix.exs` file in `deps()` section

then in shell

```
mix deps.get bump_version
mix deps.compile
```

## usage

```
mix bump_version
mix bump_version patch
mix bump_version minor
mix bump_version major
```

## help

```
mix help bump_version
```
