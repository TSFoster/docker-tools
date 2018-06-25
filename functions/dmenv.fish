function dmenv --description='set docker-machine environment'
  if [ "$argv" = '-h' ]; or [ "$argv" = '--help' ]
    set fn (status function)
    echo \
      "USAGE:

      	$fn (-h | --help)
      		This help text

      	$fn
      		Unset docker-machine environment

      	$fn [OPTIONS] MACHINE_NAME
      		Set docker-machine environment variables.
      		See docker-machine help env for information on OPTIONS." \
      | string replace --all --regex '^ +' ''
  end

  string match --quiet --regex ' [^-]' " $argv"
  or set argv --unset $argv

  eval (docker-machine env $argv --shell=fish)

  return 0
end
