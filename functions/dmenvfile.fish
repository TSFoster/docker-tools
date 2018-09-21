function dmenvfile --description='Evaluate env files for current Docker machine'
  set -l options \
  (fish_opt --short=h --long=help) \
  (fish_opt --short=d --long=dir --required-val) \
  (fish_opt --short=n --long=no-interpret) \
  (fish_opt --short=G --long=no-global) \
  (fish_opt --short=u --long=unexport) \
  (fish_opt --short=p --long=print) \
  (fish_opt --short=e --long=erase)

  argparse $options -- $argv

  if set -q _flag_help
    set fn (status function)
    echo \
      "USAGE:

      	$fn ( --help | -h )
      		This help message

      	$fn [OPTIONS]

      		Source env files from a directory (default: ./env),
      		based on machine name and machine driver.


      OPTIONS:

      	-p, --print
      		Print the commands to STDOUT instead of evaluating them

      	-G, --no-global
      		By default, variables will be set globally. This flag causes
      		variables to be unset at the end of the block.

      	-u, --unexport
      		By default, variables will be exported to child processes.
      		This flag prevents that.

      	-n, --no-interpret
      		By default, variables in env files will be interpreted. Pass
      		this argument to interpret dollar signs as literal characters.

      	-d ENVDIR, --dir=ENVDIR
      		Set directory to find env files (default: \$PWD/env).

      	-e, --erase
      		Erase variables set in relevant env files."\
    | string replace --all --regex '(^ +)' ''
    return 0
  end

  set -q _flag_dir
  and set envDir $_flag_dir
  or set envDir env

  set -q DOCKER_MACHINE_NAME
  and set -l DMN $DOCKER_MACHINE_NAME
  or set -l DMN localhost

  set tmpfile /tmp/dmenvfile-(date +%s).env

  echo "machineName=$DMN" > $tmpfile

  set filesToTry $envDir/default.env $tmpfile

  [ $DMN != localhost ]
  and set filesToTry $filesToTry $envDir/(docker-machine inspect $DMN --format '{{.DriverName}}' ^/dev/null).env

  set filesToTry $filesToTry $envDir/$DMN.env

  set -q _flag_no_interpret
  and set psFlags --no-interpret
  set -q _flag_print
  and set psFlags --print $psFlags
  set -q _flag_unexport
  and set psFlags --unexport $psFlags
  set -q _flag_no_global
  and set psFlags --no-global $psFlags
  set -q _flag_erase
  and set psFlags --erase $psFlags

  for fileToTry in $filesToTry
    [ -f $fileToTry ]
    and posix-source $fileToTry $psFlags
  end

  rm -f $tmpfile

  return 0
end
