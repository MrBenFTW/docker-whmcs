## Introduction
This Dockerfile will build a container image for nginx with php-fpm for running WHMCS. It ships with ionCube loader as well as WHMCS itself (v7.6.0 at present). The image is based on CentOS 7 and based on [my nginx-php-fpm container](https://github.com/TheKatastrophe/nginx-php-fpm).

**Note**: You will need a valid [WHMCS license](http://www.whmcs.com) to use WHMCS.

## Repositories

### GitHub
The source files for this project are available on GitHub: [https://github.com/dotsdk/docker-whmcs](https://github.com/dotsdk/docker-whmcs), Forked from: [https://github.com/TheKatastrophe/docker-whmcs](https://github.com/TheKatastrophe/docker-whmcs)

### Docker Hub
The Docker Hub page for this project can be found [here](https://hub.docker.com/r/dotsdk/whmcs/).

## Usage

### Pulling from Docker Hub
To pull this Dockerfile from Docker Hub:

	docker pull dotsdk/whmcs

### Building from source
You can build this container from source with:

	git clone https://github.com/dotsdk/docker-whmcs
	docker build -t dotsdk/whmcs:latest .

### Running
Run the container with minimal configuration and options:

	docker run --name whmcs -p 8080:8086 -d dotsdk/whmcs

This will run the container, and you can then run the WHMCS installer by browsing to http://docker-host:8080

### Other options

#### Linking volumes

Syntax: `-v /host/path:/container/path`

You can use Docker to link a path within the container to a path on the host. For example, to expose the web server's document root on the Docker host at `/opt/whmcs`, you could use:

	docker run --name whmcs -p 8080:8086 -d -v /opt/whmcs:/usr/share/nginx/ dotsdk/whmcs

#### PHP Errors

By default, PHP errors are logged but not displayed to the end user in the browser. To change this default, you can set the `ERRORS` environment variable to `true`.

Syntax: `-e 'ERRORS=true'`

#### PHP Timezone

PHP requires a timezone to be set explicitly, so we pass this in using the `PHPTZ` environment variable. If this is not specified, it will be defaulted to `Europe/London`.

Syntax: `-e 'PHPTZ=America/New_York'`
