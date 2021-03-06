complete --command=dbuild --no-files --description='Build Docker images'
complete --command=dbuild --short-option=n --long-option=no-push --description='Prevent build from being pushed to registry'
complete --command=dbuild --short-option=f --long-option=force-push --description='Force build to be pushed to registry, even if hash unchanged'
complete --command=dbuild --short-option=v --long-option=env-file --require-parameter --description='Specify alternative env file to env/build.env'
complete --command=dbuild --short-option=u --long-option=registry-url --require-parameter --description='Provide prefix, such as private registry URL or Docker Hub username'
complete --command=dbuild --short-option=d --long-option=dir --require-parameter --description='Provide path to image build directory'
complete --command=dbuild --short-option=e --long-option=erase --description='Erase all variables defined in build env file afterwards'
complete --command=dbuild --short-option=h --long-option=help --description='Show help'
