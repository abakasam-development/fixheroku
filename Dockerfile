#Grab the latest alpine image
#FROM alpine:latest
FROM heroku/heroku:20

# Install python and pip
#RUN apk add --no-cache --update python3 py3-pip bash
#ADD ./webapp/requirements.txt /tmp/requirements.txt

# Install dependencies
#RUN pip3 install --no-cache-dir -q -r /tmp/requirements.txt

# Add our code
#ADD ./webapp /opt/webapp/
#WORKDIR /opt/webapp

# Expose is NOT supported by Heroku
# EXPOSE 5000 		

# Run the image as a non-root user
#RUN adduser -D myuser
#USER myuser

# Run the app.  CMD is required to run on Heroku
# $PORT is set by Heroku			
#CMD gunicorn --bind 0.0.0.0:$PORT wsgi 

#--------------- heroku-vscode

RUN apt-get update \
 && apt-get install -y \
    curl \
    dumb-init \
    htop \
    locales \
    man \
    nano \
    git \
    procps \
    ssh \
    sudo \
    vim \
  && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml
    
#RUN cd /tmp && \
#  curl -L --silent \
#  `curl --silent "https://api.github.com/repos/cdr/code-server/releases/latest" \
#    | grep '"browser_download_url":' \
#    | grep "linux-amd64" \
#    |  sed -E 's/.*"([^"]+)".*/\1/' \
#  `| tar -xzf - && \
#  mv code-server* /usr/local/lib/code-server && \
#  ln -s /usr/local/lib/code-server/code-server /usr/local/bin/code-server

RUN cd /tmp
RUN wget https://github.com/coder/code-server/releases/download/v3.12.0/code-server-3.12.0-linux-amd64.tar.gz
RUN tar -xzf code-server-3.12.0-linux-amd64.tar.gz
RUN code-server* /usr/local/lib/code-server
RUN ln -s /usr/local/lib/code-server/code-server /usr/local/bin/code-server

ENV PORT=8080
EXPOSE 8080
USER coder
WORKDIR /home/coder
CMD sleep 5 && cat /home/coder/.config/code-server/config.yaml & /usr/local/bin/code-server --host 0.0.0.0 --port $PORT .

#---------------
