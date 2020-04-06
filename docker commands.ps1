# Allow linux commands on windows powershell
# Run command as administrator --> Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
# * Restart machine
# https://www.hanselman.com/blog/AWonderfullyUnholyAllianceRealLinuxCommandsForPowerShellWithWSLFunctionWrappers.aspx
# 
# Create profile to run setup code to allow linux comand without word "wsl"
# >>>>>> create file profile.ps1 C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1 <<<<<<<<<<<<<<




# Create alias grep to be used in powershell
new-alias grep findstr


# show docker version
docker version

# show a lot of informations like number of container and status, number of images, cpus, memory, name ...
docker info


# 1. Download image 'ngnix' from Docker Hub
# 2. Started a new container from the image
# 3. Opened port 80 on the host IP (Note: you can chage the first port (eg: 8080) if you have any application that is using port 80)
# 4. Routes that traffic to the container IP, port 80
docker run --publish 80:80 nginx

# list containters
docker container ls -a

# parameter "detach" run the image into docker with "name" webhost
docker run --publish 80:80 --detach --name webhost nginx

# parameter "volume" (-v) commonly used in database images (share datafiles)
docker container run -d --name mysql -e MYSQL_RANDOM_ROOT_PASSWORD=yes -v mysql-db:/var/lib/mysql mysql

# List Volumes
docker volume ls

# Removing contanier (use -f to force -> docker container rm -f id)
docker rm -f 047f5dd78d96 c024c7d44eaa 

# Stoping contanier
docker container stop c024c7d44eaa

# Stoping contanier
docker container start mongo

# Logs contanier
docker container logs webhost

# Running mongodb
docker container run --name mongo -d mongo        

# Running multiples contaniners (mysql, hhtpd, nginx)
# parameter "-d" detach "-e" used to set enviroment variable
docker container run -d --name mysqldb -p 3396:3396 -e MYSQL_RANDOM_ROOT_PASSWORD=yes mysql

docker pull httpd
docker container run -d --name webserver -p 8080:80 httpd

docker container run -d --name proxy -p 80:80 nginx


# process list in one container
docker container top <<mysqldb>>

# details of one contaniner config
docker container inspect
 
# performance stats for all containers (docker container stats --help)
docker container stats

#### Getting a shell inside containers

# start new container interactively
docker container run -it

Ex: docker container run -it --name proxy2 nginx bash


# run additional command in existing container
docker container exec -it mysqldb bash


# show port that container is using
docker container port mysqldb

# show a specific information from inspect output
docker container inspect --format  '{{ .NetworkSettings.IPAddress }}' webhost  

# ngnix version alpine has ping feature
docker run --publish 80:80 --detach --name webhost nginx:alpine


############# Network

# Show Networks (bridge, host, none)
# bridge -> Default docker virtual network, wich is NAT'ed behind the Host IP. (IP 172.17.0.0/16  Gateway 172.17.0.1)
# host -> It gains performance by skipping virtual networks but sacrifices security of container model. (IP 172.17.0.0/16  Gateway 172.17.0.1)
# none -> Removes eth0 and only leaves you with localhost interface in container
docker network ls

# Inspect a network
docker network inspect
Ex: docker network inspect bridge
Ex: docker network inspect my_app_net

# Create a network (default driver = bridge)
# Network driver -> Built-kn or 3rd party extension that give you virtual network features.
docker network create --driver
Ex: docker network create my_app_net
Ex2: docker container run -d --name network_nginx --network my_app_net nginx:alpine



# Attach a network to container
docker network connect <<NETWORK_ID>> <<DOCKER_ID>>
# network: my_app_net - id: d58deba2b4d7
# container: webhost - id: be3502cb0498
Ex: docker network connect d58deba2b4d7 be3502cb0498 


# Detach a network from container
docker network disconnect  <<NETWORK_ID>> <<DOCKER_ID>>
# network: my_app_net - id: d58deba2b4d7
# container: webhost - id: be3502cb0498
Ex: docker network disconnect d58deba2b4d7 be3502cb0498


## DNS
## Notice: forget IP
## Docke deamon has a built-in DNS server that containers use by default
## Containers shouldn't rely on IP's for inter-communication
## DNS for friendly names is built-in if you use custom networks
## You're using custom networks right?
## This gets way easier with Docker Compose in future

docker container run -d --name my_nginx --network my_app_net nginx:alpine  

docker network inspect my_app_net

docker container exec -it my_nginx ping my_nginx 


## Assignment (Using Containers for CLI Testing)
# * Requirements:
# 1 - Know how to use -it to get shell in container
# 2 - Understand basics of what a Linux distribution is like Ubuntu and CentOS
# 3 - Know how to run a container
#
# Exercise: 
# 
# * Use different linux distro containers to check CURL cli tool version
# * Use two different terminal windows to start bash in both CENTOSs:7 and UBUNTU:14:04, using -it
# * Learn the DOCKER CONTAINER -RM option so you can save cleanup
# * Ensure CURL is installed and on latest version for that distro
# - ubuntu: apt-get update && apt-get install curl
# - centos: yum update curl
# * Check curl--version


# Terminal 1 (CentOS)
docker container run --rm -it centos:7 bash
yum update curl

curl --version
#curl 7.29.0 (x86_64-redhat-linux-gnu) libcurl/7.29.0 NSS/3.44 zlib/1.2.7 libidn/1.28 libssh2/1.8.0
#Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtsp scp sftp smtp smtps telnet tftp
#Features: AsynchDNS GSS-Negotiate IDN IPv6 Largefile NTLM NTLM_WB SSL libz unix-sockets

exit


# Terminal 2 (Ubuntu)
docker container run --rm -it ubuntu:14.04 bash
apt-get update && apt-get install -y curl

curl --version
#curl 7.35.0 (x86_64-pc-linux-gnu) libcurl/7.35.0 OpenSSL/1.0.1f zlib/1.2.8 libidn/1.28 librtmp/2.3
#Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtmp rtsp smtp smtps telnet tftp
#Features: AsynchDNS GSS-Negotiate IDN IPv6 Largefile NTLM NTLM_WB SSL libz TLS-SRP

exit

# Terminal 3
docker container ls -a 


## Assignment (DNS Round Robin Test)
# alpine3.10
# * Requirements:
# 1 - Know how to use -it to get shell in container
# 2 - Understand basics of what a Linux distribution is like Ubuntu and CentOS 
# 3 - Know how to run a container
# 4 - Understand basics of DNS records
#
#
# * Ever since Docker Engine 1.11, we can have multiple containers on a created network respod to the same DNS address
# * Create a new virtual network (default bridge driver)
# * Create two containers from ELASTICSEARCH:2 image
# * Research and use -NETWORK-ALIAS SEARCH when creating them to give them an additional DNS name to respond to 
# * Run APLINE NSLOOKUP SEARCH with --NET to see the two containers list for the same DNS name
# * Run CENTOS CURL -S SEARCH:9200 with --NET multiple tomes until you see both "name" fields show

# create network
docker network create dude

# create/run image elasticsearch:2 and link this image with net DUDE (previous created)  
docker container run -d  --net dude --net-alias search elasticsearch:2
# Execute the same comand twice
docker container run -d  --net dude --net-alias search elasticsearch:2

# Show containers created above
docker container ls  
#CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                NAMES
#ae3969544f1f        elasticsearch:2        "/docker-entrypoint.…"   15 minutes ago      Up 15 minutes       9200/tcp, 9300/tcp   distracted_yalow
#abf7213b3d45        elasticsearch:2        "/docker-entrypoint.…"   19 minutes ago      Up 18 minutes       9200/tcp, 9300/tcp   gallant_archimedes


# create/run image alpine link with dude network and lookup using net-alias "search" (configured in elasticsearch:2 image)
# parameter -rm: Automatically remove the container when it exits
docker container run --rm --net dude alpine nslookup search
# Server:         127.0.0.11
# Address:        127.0.0.11:53
# 
# Non-authoritative answer:
# 
# Non-authoritative answer:
# Name:   search
# Address: 172.20.0.3
# Name:   search
# Address: 172.20.0.2


#  run image centos:7 on DUDE network and execute command "curl -s search:9200"
# Notice that each execution return differents "name" (round robin)
docker container run --rm --net dude centos:7 curl -s search:9200
#{
#  "name" : "Wildside",
#  "cluster_name" : "elasticsearch",
#  "cluster_uuid" : "Jn2vsfVvQHu5cIhSY9ePaA",
#  "version" : {
#    "number" : "2.4.6",
#    "build_hash" : "5376dca9f70f3abef96a77f4bb22720ace8240fd",
#    "build_timestamp" : "2017-07-18T12:17:44Z",
#    "build_snapshot" : false,
#    "lucene_version" : "5.5.4"
#  },
#  "tagline" : "You Know, for Search"
#}
docker container run --rm --net dude centos:7 curl -s search:9200 

#{
#  "name" : "Charles Xavier",
#  "cluster_name" : "elasticsearch",
#  "cluster_uuid" : "q-3vmKCcS5i4x4hpO0XYIw",
#  "version" : {
#    "number" : "2.4.6",
#    "build_hash" : "5376dca9f70f3abef96a77f4bb22720ace8240fd",
#    "build_timestamp" : "2017-07-18T12:17:44Z",
#    "build_snapshot" : false,
#    "lucene_version" : "5.5.4"
#  },
#  "tagline" : "You Know, for Search"
#}

# remove elasticsearch containers
docker container rm -f ae3969544f1f abf7213b3d45

