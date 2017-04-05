### App deployment script to create a new LXC Container via Docker
###
### Docker: https://www.docker.com

FROM nginx:1.10
MAINTAINER Zongzhi Bai "dolphineor@gmail.com"

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Update & Install System Dependencies
RUN apt-get update && \
    apt-get -y install build-essential mercurial mysql-client mysql-server curl vim pwgen git-core python-setuptools

# Install & Verify Go
WORKDIR /root
RUN mkdir -p /root/go/{bin, pkg, src}
RUN curl -qO https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz
RUN tar -xzf go1.8.linux-amd64.tar.gz -C /usr/local
RUN rm -f go1.8.linux-amd64.tar.gz
ENV GOROOT /usr/local/go
ENV GOPATH /root/go
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH
RUN go version
RUN go env

# Install Supervisor
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout

# Get App Dependencies
RUN go get -v github.com/revel/revel github.com/revel/cmd/revel golang.org/x/crypto/bcrypt github.com/go-sql-driver/mysql

# Add Nginx frontend host
ADD ./docker/nginx_app.vhost /etc/nginx/sites-available/default

# Stage App
ENV APP_PATH github.com/lavenderx/revel-app-scaffold
ADD . $GOPATH/src/$APP_PATH

# Setup Nginx
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Setup Supervisord
RUN cp $GOPATH/src/$APP_PATH/docker/supervisord.conf /etc/supervisord.conf

# Set start script permissions
RUN cp $GOPATH/src/$APP_PATH/docker/start.sh /start.sh
RUN chmod 755 /start.sh

# Expose Web Frontend (Nginx) port only
EXPOSE 80

# Start required services when docker is instantiated
ENTRYPOINT ["/bin/bash", "/start.sh"]
