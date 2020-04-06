# Persistent Data: <<< BIND MOUNTING >>>
#
# * Maps a host file or directory to a container file or directory
# * Basically just two locations pointing to the same file(s)
# * Again, skips UFS, and host files overwrite any in container
# * Can't use in Dockerfile, must be at container run
# * ... run -v /Users/bret/stuff:/path/container (mac/linux)
# * ... run -v //c/Users/bret/stuff:/path/container (windows)

# -v -> ${pwd} = local directory | "/usr/share/nginx/html" = path into image
docker containter run -d --name nginx -p 80:80 -v ${pwd}:/usr/share/nginx/html nginx


# Persistent Data: <<< NAMED VOLUMES >>>
# >>>>>> EXERCISE
# * Database upgrade with containers
# * Create a postgres container with named volume psql-data using version 9.6.1
docker container run -d --name psql -v psql:/var/lib/postgresql/data postgres:9.6.1
# * Use Docker Hub to learn VOLUME path an versions needed to run it 
# * Check logs, stop container
docker container logs -f psql
docker stop 4a2c303a12b3
# * Create a new POSTGRES contauner with same named volume using 9.6.2
docker container run -d --name psql2 -v psql:/var/lib/postgresql/data postgres:9.6.2
# * Check logs to validade
docker container logs -f psql2
# * (this only works with patch versions, most SQL DB's require manual commands to upgrade DB's to major/minor versions, i.e. it's a DB limitation not a container on)



