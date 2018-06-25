# Docker tools

Functions and commands for working with Docker and Docker Machine

## Install

With [fisherman]

```
fisher TSFoster/docker-tools
```

## Usage

### `dmenv`

```fish
dmenv --help # Print help
dmenv MACHINE_NAME # Run "eval (docker-machine env MACHINE_NAME --shell=fish)"
dmenv # Run "eval (docker-machine env --unset --shell=fish)"
```

[fisherman]: https://github.com/fisherman/fisherman
