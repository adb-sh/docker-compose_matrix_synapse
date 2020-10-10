# docker-compose_matrix_synapse

a complete working docker-compose setup for the matrix synapse server with postgres

## create config files

* Change `your.domain` in the `create_config.sh` file and simply run the script from terminal.
* A temporarily docker cotainer will be created, that will configurate the configs for you.
* You will find your finished configs at `/var/lib/docker/volumes/synapse-data/_data`.
* Copy this files to `./synapse_data/` in your docker-compose working directory.

for more details have a look at: [hub.docker.com/r/matrixdotorg/synapse](https://hub.docker.com/r/matrixdotorg/synapse)

## configurate `./synapse_data/homserver.yaml`

### database

* comment out the standard sqlite3 config (about line 680)
* just below add:
```
database:
  name: psycopg2
  args:
    user: matrix
    password: your-secret-pw
    database: synapse
    host: db
    cp_min: 5
    cp_max: 10
```
* change the password

### registration

* if you want you can enable user registration by outcommenting `enable_registration: true` (typically line 1036)

## configurate `docker-compose.yml`

* chnage the postgres password to the password you've set before.

## create docker containers


```
cd /your/docker-compose/working/directory
docker-compose -p matrix up -d
```

If you can see the concrats page at `http://127.0.0.1:8008/` everything is working. This might take a few minutes, as the database has to be created.

## nginx config

To manage SSL/TLS I'm using nginx.

Just add another path to your working SSL v-host server, like this:
```
    #matrix server

    #For the federation port
    listen 8448 ssl default_server;
    listen [::]:8448 ssl default_server;

    location /_matrix {
        proxy_pass http://127.0.0.1:8008;
        proxy_set_header X-Forwarded-For $remote_addr;
        # Nginx by default only allows file uploads up to 1M in size
        # Increase client_max_body_size to match max_upload_size defined in homeserver.yaml
        client_max_body_size 10M;
    }
```
The full v-host server config might look like:
```
server {
    server_name your.domain;

    #main web server
    listen [::]:443 ssl ipv6only=on;
    listen 443 ssl;

	root /var/www/your.domain;
	index index.html;

    #matrix server

    #For the federation port
    listen 8448 ssl default_server;
    listen [::]:8448 ssl default_server;

    location /_matrix {
        proxy_pass http://127.0.0.1:8008;
        proxy_set_header X-Forwarded-For $remote_addr;
        # Nginx by default only allows file uploads up to 1M in size
        # Increase client_max_body_size to match max_upload_size defined in homeserver.yaml
        client_max_body_size 10M;
    }

    ssl_certificate /etc/letsencrypt/live/your.domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your.domain/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

}
server {
    if ($host = your.domain) {
        return 302 https://$host$request_uri;
    }

	listen 80;
	listen [::]:80;

	server_name your.domain;
    return 404;
}
```

//and thats it, good luck :D