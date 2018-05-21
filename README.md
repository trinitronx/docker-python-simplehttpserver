Docker Python SimpleHTTPServer
==============================
[![Build Status](https://img.shields.io/travis/trinitronx/docker-python-simplehttpserver.svg)](https://travis-ci.org/trinitronx/docker-python-simplehttpserver)
[![Docker Pulls](https://img.shields.io/docker/pulls/trinitronx/python-simplehttpserver.svg)](https://hub.docker.com/r/trinitronx/python-simplehttpserver)
[![Docker Stars](https://img.shields.io/docker/stars/trinitronx/python-simplehttpserver.svg)](https://hub.docker.com/r/trinitronx/python-simplehttpserver)
[![Liberapay goal progress](https://img.shields.io/liberapay/goal/trinitronx.svg)](https://en.liberapay.com/trinitronx)

A Simple & Compact (< ~8.5 MB) Python webserver in a Docker Container.

By default, listens on port `8080`

To serve files, volume mount a directory to `/var/www` inside the container.

Example Usage
-------------

To listen on port `8080` and serve files from directory `/tmp/` on the host:

    sudo docker run -d -v /tmp/:/var/www:ro -p 8080:8080 trinitronx/python-simplehttpserver

To listen on port `80` and serve files from directory `/home/foo` on the host:

    sudo docker run --name python_simplehttpserver -d -v /home/foo:/var/www:ro -p 80:8080 trinitronx/python-simplehttpserver

To run server so it is only accessible to linked containers:

    sudo docker run --name python_simplehttpserver -d -v /tmp/:/var/www:ro -p 8080:8080 trinitronx/python-simplehttpserver
    # Then run your container & link it...
    sudo docker run -ti --link python_simplehttpserver busybox wget -O -  http://python_simplehttpserver:8080/
    
    # Another example:
    # Use with trinitronx/fastest-servers as a MIRRORLIST_HOST for serving up mirrors.txt file for fastest-servers.rb to filter down to fastest found
    sudo docker run -ti --link python_simplehttpserver -e FASTEST_SERVER_DEBUG=true -e MIRRORLIST_HOST=python_simplehttpserver -e MIRRORLIST_PORT=8080 -v /tmp/:/tmp/ trinitronx/fastest-servers


