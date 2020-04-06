#### Container IMAGES


## * What's in an Image (and what ins't)
# - App binaries and dependencies
# - Metadata about the image data and how to run the image
# - Official Definition: "An Image is an ordered collection of root filesystem changes and the corresponding execution parameters for use within a container runtime."
# - Not a cimplete OS. No kernel, kernel modules (e.g. drivers)
# - Small as one file (your app binary) like a golang static binary
# - Big as a Ubuntu distro with apt, and Apache, PHP, and more installed

# List images
docker image ls

# Downoad image - Ex. docker pull nginx:<<version>>
docker pull nginx

# History (Old Way) -> Show layers of changes made in image
docker image history nginx:latest

# Inspect (Old Way) -> Returns JSON metadata about the image
docker image inspect nginx:latest

# Tag image
Eg1: docker image tag spring-rest-jpa-swagger hhigute/spring-rest-jpa-swagger
Eg2: docker image tag hhigute/spring-rest-jpa-swagger hhigute/spring-rest-jpa-swagger:testing

# Docker login
docker login

# Get login/authenticaton info (execute on user path eg: C:\Users\helto)
cat .docker/config.json

# Upload image to docker hub
Eg1: docker image push hhigute/spring-rest-jpa-swagger
Eg2: docker image push hhigute/spring-rest-jpa-swagger:testing


#>  # Create file "DOCKERFILE" (Basics)
#>  # docker build -f some-dockerfile
#>  # All images must have a FROM -> dependecies 
#>  # Eg: FROM debian:jessie
#>  FROM java:8
#>  
#>  
#>  # ENV -> Used to set enviroment variables
#>  # Environment Variables: One reason they were chosen as preferred way to inject key/value is they work everywhere, on every OS and config
#>  # Eg: ENV NGINX_VERSION 1.11.10-1-jessie
#>  
#>  
#>  
#>  # RUN -> Used when you need to execute some commands like install packages, zip/compact something...
#>  # optional commands to run at shell inside container at build time
#>  # Eg:	RUN apt-key --keyserver hkp://pgp.mit.edu:80 --recv--keys 13148947874631asda65d46d \
#>  #			&& echo "deb hhtp://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/source.list \
#>  #			&& apt-get update \			
#>  #			&& apt-get install 	--no-intall-recomends --no-intall-suggests -y \
#>  #								ca-certificates \
#>  #			&& rm -rf /var/lib/apt/lists/* 			
#>  
#>  
#>  # EXPOSE -> Expose these ports on the docker virtual network
#>  # you still need to use -p or -P to open/forward these ports on host
#>  EXPOSE 7001
#>  
#>  # CMD -> required to run this command when container is launched
#>  # only one CMD allowed, so if there are multiple, last one wins
#>  # Eg: CMD["nginx","-g","daemon off;]
#>  
#>  
#>  
#>  ADD /target/spring-rest-jpa-swagger-0.0.1-SNAPSHOT.jar spring-rest-jpa-swagger.jar
#>  ENTRYPOINT ["java", "-jar", "spring-rest-jpa-swagger.jar"]

# Example DOCKERFILE to build spring app
# Note: Your app must not use log file (only stdout), the docker file do the rest
#
# FROM java:8
# EXPOSE 7001
# ADD /target/spring-rest-jpa-swagger-0.0.1-SNAPSHOT.jar spring-rest-jpa-swagger.jar
# ENTRYPOINT ["java", "-jar", "spring-rest-jpa-swagger.jar"]



# Build docker image file
docker build -f DockerFile -t spring-rest-jpa-swagger:test2 .



# EXERCISE "dockerfile-assignment-1"
# Path ==> C:\workspaces\container\study\udemy-docker-mastery\dockerfile-assignment-1

# Instructions from the app developer
# - you should use the 'node' official image, with the alpine 6.x branch
FROM node:6-alpine
# - this app listens on port 3000, but the container should launch on port 80
  #  so it will respond to http://localhost:80 on your computer
EXPOSE 3000
# - then it should use alpine package manager to install tini: 'apk add --update tini'
RUN apk add --update tini
#m - then it should create directory /usr/src/app for app files with 'mkdir -p /usr/src/app'
RUN mkdir -p /usr/src/app
# - Node uses a "package manager", so it needs to copy in package.json file
WORKDIR  /usr/src/app
COPY package.json package.json
# - then it needs to run 'npm install' to install dependencies from that file
RUN npm install && npm cache clean
# - to keep it clean and small, run 'npm cache clean --force' after above
# - then it needs to copy in all files from current directory
COPY . .
# - then it needs to start container with command '/sbin/tini -- node ./bin/www'
CMD ["tini","--","node","./bin/www"]
# - in the end you should be using FROM, RUN, WORKDIR, COPY, EXPOSE, and CMD commands

# you can use "prune" commands to clean up images, volumes, build cache and containers
docker image prune 