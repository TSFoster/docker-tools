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

### `dmenvfile`

```fish
dmenvfile --help # Print help
dmenvfile # Source files related to $DOCKER_MACHINE_NAME in ./env directory
dmenvfile --print --dir=other/env/path --unexport --no-global
```

Sources posix-style env files, in order, related to the current `$DOCKER_MACHINE_NAME`:

1.  Sets `$machineName` to `$DOCKER_MACHINE_NAME` or `localhost`
2.  Sources `env/default.env` if it exists
3.  Sources `env/[[MACHINE-DRIVER]].env` (e.g. `env/virtualbox.env`)
4.  Sources `env/$DOCKER_MACHINE_NAME.env`

##### Example usage:

###### Filesystem:

- awesome-project/
  - bin/
    - deploy
  - env/
    - default.env
    - virtualbox.env
    - digitalocean.env
    - awesome-project-staging.env
    - awesome-project-prod.env
  - stack.yml

###### `stack.yml`

```yml
  [...]
    deploy:
      labels:
        - "traefik.frontend.rule=Host:${hostName},www.${hostName}"
        - "traefik.backend=${stackName}_rails"
  [...]
    environment:
      RAILS_ENV: ${RAILS_ENV}
  [...]
```

###### `bin/deploy`

```fish
#!/usr/bin/env fish

cd (dirname (status filename))/..
dmenvfile
docker stack deploy --compose-file=stack.yml awesome-project
```

###### `env/default.env`

```bash
stackName=awesomeproj
```

###### `env/virtualbox.env`

```bash
hostName=$stackName.$machineName
RAILS_ENV=development
```

###### `env/digitalocean.env`

```bash
hostName=awesome-project.com
```

###### `env/awesome-project-staging.env`

```bash
RAILS_ENV=production
hostName=staging.$hostName
```

###### `env/awesome-project-prod.env`

```bash
RAILS_ENV=production
```

###### To deploy

```fish
dmenv awesome-project-dev
/path/to/awesome-project/bin/deploy
```

1.  Sets `$machineName` to `awesome-project-dev`
2.  Sources `env/default.env`, sets `$stackName` to `awesomeproj`
3.  Sources `env/virtualbox.env`, sets `$hostName` to `awesomeproj.awesome-project-dev` and `RAILS_ENV` to `development`
4.  `env/awesome-project-dev.env` doesn’t exist, so skipped
5.  Deploys stack.yml

[fisherman]: https://github.com/fisherman/fisherman
