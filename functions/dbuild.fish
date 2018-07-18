function dbuild --description='Build Docker images'
  set -l options \
  (fish_opt --short=n --long=no-push) \
  (fish_opt --short=f --long=force-push) \
  (fish_opt --short=e --long=env-file --multiple-vals) \
  (fish_opt --short=u --long=registry-url --required-val) \
  (fish_opt --short=p --long=build-path --multiple-vals) \
  (fish_opt --short=e --long=erase) \
  (fish_opt --short=h --long=help)

  argparse $options -- $argv

  if set -q _flag_help
    set fn (status function)
    echo \
      "USAGE:

      	$fn ( --help | -h )
      		This help message

      	$fn [OPTIONS] [ IMAGE_NAMES ]

      		Build images after sourcing env file.


      IMAGE_NAMES:

      	Image names take the format NAME[:TAG]. A common prefix (e.g.
      	Docker Hub username, or private Docker registry URL) can be
      	provided by setting --registry-url or \$dbuildRegistryUrl.
      	If no tag is provided, ‘latest’ is used.


      OPTIONS:

      	-n, --no-push
      		Don’t push the built image

      	-f, --force-push
      		Push the built image, even if no change to the build
      		is detected.

      	-e FILE, --env-file=FILE
      		By default, env/build.env is sourced if it exists.
      		This flag allows for different files to be specified.

      	-u URL, --registry-url=URL
      		A common prefix to the build tags can be specified,
      		either with this flag or by setting \$dbuildRegistryUrl.

      	-p PATH, --build-path=PATH
      		By default, a Dockerfile is searched for in a directory
      		with the image name, then in \$PWD. This flag will
      		overwrite these locations. The flag can be used once for
      		each image specified. Alternatively, \$dbuildBuildPaths
      		can be set.

      	-e, --erase
      		Erase all variables defined in env files afterwards."\
    | string replace --all --regex '(^ +)' ''
    return 0
  end

  set -q _flag_env_file
  and set envFiles $_flag_env_file
  or set envFiles env/build.env

  for envFile in $envFiles
    [ -f "$envFile" ]
    and posix-source $envFile
    or echo "$envFile doesn’t exist, not sourcing" >&2
  end

  set -q dbuildRegistryUrl
  and set registryUrl $dbuildRegistryUrl
  set -q _flag_registry_url
  and set registryUrl $_flag_registry_url

  [ -n "$registryUrl" ]
  and [ (string sub --start -1 "$registryUrl") != '/' ]
  and set registryUrl "$registryUrl/"

  set -q regsitryUrl
  and echo "Using $registryUrl as base URL" >&2

  [ (count $argv) -eq 0 ]
  and set toBuild $dbuildValidImages
  or set toBuild $argv

  if [ (count $toBuild) -eq 0 ]
    echo 'Don’t know what to build!' >&2
    echo 'Try setting $dbuildValidImages, or passing image names as arguments' >&2
    set -q _flag_erase
    and posix-source -e $envFiles
    return 1
  end

  set -q dbuildBuildPaths
  and set buildPaths $dbuildBuildPaths

  set -q _flag_build_path
  and set buildPaths $_flag_build_path

  dmenv

  for imagetag in $toBuild
    set image (string split ':' $imagetag)[1]
    set tag (string split ':' $imagetag)[2]
    [ -z "$tag" ]; and set tag latest

    if set -q dbuildValidImages; and not contains $image $dbuildValidImages
      echo "$image not a valid image name, skipping." >&2
      continue
    end

    set fullName $registryUrl$image:$tag

    if set -q buildPaths
      set buildPath $buildPaths[1]
      set buildPaths $buildPaths[2..-1]
    else
      [ -f "$image/Dockerfile" ]
      and set buildPath $image
      or set buildPath .
    end

    not [ -f $buildPath/Dockerfile ]
    and echo "Can’t find Dockerfile to build for $image!" >&2
    and continue

    set previousId (docker image inspect $fullName --format '{{.Id}}' ^ /dev/null)
    docker build -t $fullName $buildPath
    set newId (docker image inspect $fullName --format '{{.Id}}')
    if set -q _flag_force_push; or [ "$newId" != "$previousId" ]
      not set -q _flag_no_push
      and docker push $fullName
      or echo "Not pushing $fullName due to --no-push flag" >&2
    else
      [ "$newId" = "$previousId" ]
      and echo "Not pushing $fullName due to no change to build hash" >&2
    end
  end

  set -q _flag_erase
  and posix-source -e $envFiles

  return 0
end
