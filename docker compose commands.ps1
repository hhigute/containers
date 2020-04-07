# POSTGRES_PASSWORD=mypassword
# POSTGRES_HOST_AUTH_METHOD=trust

# >>>> DOCKER COMPOSE
# * Why: configure relationships between containers
# * Why: save our docker container run settings in easy-to-read file
# * Why: create one-liner developer environment statups
# * Compised of 2 separate but related things
#     - 1. YAML-formatted file that describer our solution options for:
#       > containers
#       > networks
#       > volumes
#     - 2. A CLI tool DOCKER-COMPOSE used for local dev/test automation with those YAML files.

# >>> docker-compose.ymml
#
# * Compose YAML format has it's own versions: 1, 2, 2.1, 3, 3.1
# * YAML file can be used with docker-compose command for local docker automation or ...
# * With docker directly in production with SWARM (as of v1.13)
# * docker-compose --help
# * docker-compose.yml is default filename, but any can ve used with docker-compose -f

# Example:

version: '2'

# same as 
# docker run -p 80:4000 -v $(pwd):/site bretfisher/jekyll-serve

services:
  jekyll:
    image: bretfisher/jekyll-serve
    volumes:
      - .:/site
    ports:
      - '80:4000'

# >>>>>> docker-compose CLI
# 
# * CLI tool comes with Docker for Wundows/Max, but separate download for Linux
# * Not a production-grade tool but ideal for local development and test
# * Two most common commands are
# - docker-compose up --> setup volumes/networks and start all containers
# - docker-compose down --> stop all containser and remove cont/vol/net
# * If all your projects had a Dockerfile and docker-compose.yml the "new developer onboarding" would be:
# - git clone github.com/some/software
# - docker-compose up
#
# PS C:\workspaces\containers\study\compose-sample-2> docker-compose up
# Creating network "compose-sample-2_default" with the default driver
# Pulling proxy (nginx:1.13)...
# 1.13: Pulling from library/nginx
# f2aa67a397c4: Pull complete
# 3c091c23e29d: Pull complete
# 4a99993b8636: Pull complete
# Digest: sha256:b1d09e9718890e6ebbbd2bc319ef1611559e30ce1b6f56b2e3b479d9da51dc35
# Status: Downloaded newer image for nginx:1.13
# Creating compose-sample-2_proxy_1 ... done
# Creating compose-sample-2_web_1   ... done
# Attaching to compose-sample-2_web_1, compose-sample-2_proxy_1
# web_1    | AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.19.0.2. Set the 'ServerName' directive globally to suppress this message
# web_1    | AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.19.0.2. Set the 'ServerName' directive globally to suppress this message
# web_1    | [Mon Apr 06 23:50:15.603095 2020] [mpm_event:notice] [pid 1:tid 140257300808832] AH00489: Apache/2.4.43 (Unix) configured -- resuming normal operations
# web_1    | [Mon Apr 06 23:50:15.605734 2020] [core:notice] [pid 1:tid 140257300808832] AH00094: Command line: 'httpd -D FOREGROUND'
# proxy_1  | 172.19.0.1 - - [06/Apr/2020:23:51:00 +0000] "GET / HTTP/1.1" 200 45 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36" "-"
# web_1    | 172.19.0.3 - - [06/Apr/2020:23:51:00 +0000] "GET / HTTP/1.0" 200 45


# >>>>>> Assignment: Writing A Compose file
#
# * Build a busic compose file for a Drupal content management system website. Docker Hub is your friend
# * Use the DRUPAL image along with the POSTGRES image
# * Use PORTS to expose Drupal on 8080 so you can localhost:8080
# * Be sure to set POSTGRES_PASSWORD for postgres
# * Walk though Drupal setup via browser
# * Tip: Drupal assumes DB is LOCALHOST, but it's service name
# * Extra Credit: Use volumes to dtore DRUPAL unique data

version: '2'

services: 
    drupal:
        image: drupal
        ports: 
            - '8080:80'
        volumes: 
            - drupal-modules:/var/www/html/modules 
            - drupal-profiles:/var/www/html/profiles 
            - drupal-sites:/var/www/html/sites 
            - drupal-themes:/var/www/html/themes 
    postgresdb:
        image: postgres
        environment: 
            - POSTGRES_DB=drupal 
            - POSTGRES_USER=user
            - POSTGRES_PASSWORD=mypass
volumes: 
    drupal-modules:
    drupal-profiles:
    drupal-sites:
    drupal-themes:        

# run/start
docker-compose up        

# stop
docker-compose down -v

# >>>>> USing compose to build
#
# * Compose can also build your custom images
# * Will build them with DOCKER-COMPOSE UP if not found in cache
# * Also rebuild with DOCKER-COMPOSE BUILD
# * Great for complex builds that have lots of vars or build args

# Dockerfile
FROM drupal:8.8.2

RUN apt-get update && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html/themes

RUN git clone --branch 8.x-3.x --single-branch --depth 1 https://git.drupal.org/project/bootstrap.git \
    && chown -R www-data:www-data bootstrap

WORKDIR /var/www/html    



# docker-compose.yml
version: '2'

services: 
    drupal:
        image: custom-drupal
        build: .
        ports: 
            - '8080:80'
        volumes: 
            - drupal-modules:/var/www/html/modules 
            - drupal-profiles:/var/www/html/profiles 
            - drupal-sites:/var/www/html/sites 
            - drupal-themes:/var/www/html/themes 
    postgresdb:
        image: postgres
        environment: 
            - POSTGRES_DB=drupal 
            - POSTGRES_USER=user
            - POSTGRES_PASSWORD=mypass
        volumes: 
            - drupal-data:/var/lib/postgresql/data
volumes: 
    drupal-data:
    drupal-modules:
    drupal-profiles:
    drupal-sites:
    drupal-themes:
