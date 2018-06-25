complete --command=dmenv --no-files --description='Set docker-machine environment variables'
complete --command=dmenv --no-files --arguments='(docker-machine ls -f "{{.Name}}")'
complete --command=dmenv --short-option=h --long-opion=help='Print help'
