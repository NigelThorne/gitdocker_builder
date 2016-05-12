# Git AutoDockerBuild

This is step one in my attempt to automate my docker pipeline. This is not supopsed to be a 'production' tool. I'm using it to help develop internal tools that I can control the hosting of.

I want to make deploying networks of connected services as simple as possible for coders.

I want to be able to develop services by: 
* Implement the service code and add a "Dockerfile" to the codebase.
* `git push` the repo to have an image build and registered.
* Define a repo with a `docker-compose.yml` file.
* `git push` the docker-compose repo to trigger deployment of the services to a docker server environment (staging or production based on the git remote used).

This project leans heavily on 
* Gitreceive https://github.com/progrium/gitreceive
* Dind (Docker in Docker)

Build the image and run it as follows

`docker build -t gitreceive .`
`docker run gitreceive`

To allow someone push to gitreceive, you need to add their public key.

`cat /path/to/user/key.pub | ssh -i sshkey root@<DOCKER_HOST> -p <CONTAINER_PORT> "gitreceive upload-key <username>"`

The container will expose port 22 (default ssh port) and have a docker volume mounted at /home/git.

*The ssh keys are provided for convenience. You must create your own in any serious use.*

The version of gitreceive can be upgraded by feting a new version from guthub
`wget https://raw.github.com/progrium/gitreceive/master/gitreceive`

#The current deployment process...
I assume you have a docker registry running, and a 'docker in docker' image running. This container requires linked 'docker' and 'register' images.

Here is what I do:

##Run registry
`docker run -d -p 5000:5000 --restart=always --name registry registry:2`

##Starts docker server
`docker run --privileged --restart=always --name some-docker --link registry:registry -d docker:1.11-dind --insecure-registry registry:5000`

##Run this server
`docker run --link some-docker:docker --link registry:registry  --restart=always -p 34567:22 -d --name gitreceive` 

##Add your ssh key
`cat ~/.ssh/id_rsa.pub | ssh -i sshkey root@192.168.99.100 -p 34567 "gitreceive upload-key $(whoami)"`

#Working: 
At the moment you can push a repo (to remote: git@192.168.99.100:xxx) with a valid `Dockerfile`, and it will use the 'docker in docker' image to build the project and publish the resulting image to the linked registry.

#TODO:
* On receiving a repo with compose.yml files, deploy the configuration to the linked docker server.
* handle errors
* handle 'upgrading a service'
* handle 'multiple users pushing forks of an image'
* handle 'environments' -- maybe just run two parallel stacks.
* Add a docker-compose.yml for this configuation so you can spin up all 3 services at once.

