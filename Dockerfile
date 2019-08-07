# Pull a pre-built alpine docker image with nginx and python3 installed
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils 2>&1 \
    && apt-get install -y python3.7 python3-pip python3.7-dev
    
# Set the port on which the app runs; make both values the same.
#
# IMPORTANT: When deploying to Azure App Service, go to the App Service on the Azure 
# portal, navigate to the Applications Settings blade, and create a setting named
# WEBSITES_PORT with a value that matches the port here (the Azure default is 80).
# You can also create a setting through the App Service Extension in VS Code.
ENV LISTEN_PORT=4000
EXPOSE 4000

# Indicate where uwsgi.ini lives
ENV UWSGI_INI uwsgi.ini

# Tell nginx where static files live. Typically, developers place static files for
# multiple apps in a shared folder, but for the purposes here we can use the one
# app's folder. Note that when multiple apps share a folder, you should create subfolders
# with the same name as the app underneath "static" so there aren't any collisions
# when all those static files are collected together.
ENV STATIC_URL /hello_app/static

# Set the folder where uwsgi looks for the app
WORKDIR /hello_app

# Copy the app contents to the image
COPY . /hello_app

# If you have additional requirements beyond Flask (which is included in the
# base image), generate a requirements.txt file with pip freeze and uncomment
# the next three lines.
# COPY requirements.txt /
RUN python3.7 -m pip install --no-cache-dir -U pip
RUN python3.7 -m pip install --no-cache-dir -r requirements.txt
RUN python3.7 -m pip install pylint ptvsd

# Install git, process tools, lsb-release (common in install instructions for CLIs)
RUN apt-get -y install git procps lsb-release iproute2

# Install any missing dependencies for enhanced language service
RUN apt-get install -y libicu[0-9][0-9]


# Set the default shell to bash rather than sh
ENV SHELL /bin/bash

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc/ \
    && rm -rf /usr/share/man/

ENV DEBIAN_FRONTEND=dialog
