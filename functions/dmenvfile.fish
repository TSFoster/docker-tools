function dmenvfile --description='Evaluate env files for current Docker machine'
  set -l options \
  (fish_opt --short=h --long=help) \
  (fish_opt --short=d --long=dir --required-val) \
  (fish_opt --short=n --long=no-interpret) \
  (fish_opt --short=p --long=print)

  argparse $options -- $argv

  if set -q _flag_help
    set fn (status function)
    echo \
      "USAGE:

      	$fn ( --help | -h )
      		This help message

      	$fn [ -d ENVDIR | --dir=ENVDIR ] [ -n | --no-interpret ] [ -p | --print ]

      		Source env files from a directory (default: ./env),
      		based on machine name and machine driver.


      OPTIONS:

      	-p, --print
      		Print the commands to STDOUT instead of evaluating them

      	-n, --no-interpret
      		By default, variables in env files will be interpreted. Pass
      		this argument to interpret dollar signs as literal characters.

      	-d ENVDIR, --dir=ENVDIR
      		Set directory to find env files (default: \$PWD/env)."\
    | string replace --all --regex '(^ +)' ''
    return 0
  end

  set -q _flag_dir
  and set envDir $_flag_dir
  or set envDir env

  set filesToTry default

  set -q DOCKER_MACHINE_NAME
  and set -gx machineName $DOCKER_MACHINE_NAME
  or set -gx machineName localhost

  [ $machineName != localhost ]
  and set filesToTry $filesToTry (docker-machine inspect $machineName --format '{{.DriverName}}' ^/dev/null)

  set filesToTry $filesToTry $machineName

  set psFlags
  set -q _flag_no_interpret
  and set psFlags --no-interpret
  set -q _flag_print
  and set psFlags --print $psFlags

  for fileToTry in $filesToTry
    [ -f $envDir/$fileToTry.env ]
    and posix-source $envDir/$fileToTry.env $psFlags
  end

  return 0
end
