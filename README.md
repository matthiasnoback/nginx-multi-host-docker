# Setup for running multiple websites on a single server

- Uses Nginx as a proxy server, and the [docker-gen](https://github.com/jwilder/docker-gen) and [docker-letsencrypt-nginx-proxy-companion](https://github.com/jwilder/docker-letsencrypt-nginx-proxy-companion) container utilities. 
- Serves secure websites with automatically generated and renewed [Let's Encrypt](http://letsencrypt.org/) certificates.
- Only exposes one web server, connects to other web servers using a custom network.

## Usage

- If you didn't do so already, set up a server using `docker-machine create`.
- Export the name you used for the server as the environment variable `DOCKER_MACHINE_NAME`, e.g.:

    export DOCKER_MACHINE_NAME=personal-websites

- Run `./deploy.sh` to install the Nginx proxy server.

Now *for every website* you want to expose on the same server:

1. Write a Dockerfile for the website server, for example (assuming that copying some files to the default document root is sufficient):

    ```
    FROM nginx:1.11-alpine
    RUN rm -rf /usr/share/nginx/html
    COPY web /usr/share/nginx/html
    ```

2. Define a service for that container in `docker-compose.yml`:

    ```
    version: '2'
    
    services:
        website:
            image: your-username/your-website-name
            build:
                context: .
                dockerfile: Dockerfile
            restart: always
            environment:
                - VIRTUAL_HOST=your.hostname.com
                - VIRTUAL_NETWORK=nginx-proxy
                - LETSENCRYPT_HOST=your.hostname.com
                - LETSENCRYPT_EMAIL=your@email.com
            networks:
                - proxy-tier
    
    networks:
        proxy-tier:
            external:
                name: nginx-proxy
    ```

3. Deploy the website by running the following commands (of course it would make sense to automate this):

    ```
    eval $(docker-machine env $DOCKER_MACHINE_NAME)
    docker network create --driver bridge nginx-proxy || true
    docker-compose pull
    docker-compose up -d --force-recreate --no-build
    docker-compose ps
    eval $(docker-machine env -u)
    ```

It may take a minute or so before the secure site can be reached (because the certificate has to be created first).
