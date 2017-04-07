### App deployment script to create a new LXC Container via Docker
###
### Docker: https://www.docker.com

FROM nginx:1.10.3
MAINTAINER Zongzhi Bai "dolphineor@gmail.com"

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Update & Install System Dependencies
RUN apt-get update && \
    apt-get -y install build-essential mysql-client mysql-server curl vim pwgen git-core python-setuptools

# Install & Verify Go
ENV GOLANG_VERSION 1.8
WORKDIR /root
RUN mkdir -p /root/go/bin
RUN curl -qO https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz
RUN tar -xzf go$GOLANG_VERSION.linux-amd64.tar.gz -C /usr/local
RUN rm -f go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOROOT /usr/local/go
ENV GOPATH /root/go
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH
RUN go env

# Install Supervisor
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout

# Set Time Zone
RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# Get App Dependencies
RUN go get -v github.com/revel/revel \
    github.com/revel/cmd/revel \
    github.com/go-sql-driver/mysql

# Stage App
ENV APP_PATH github.com/lavenderx/revel-app-scaffold
ADD . $GOPATH/src/$APP_PATH
RUN rm -rf $GOPATH/src/$APP_PATH/.idea/ && \
    rm -rf $GOPATH/src/$APP_PATH/.git/ && \
    rm -rf $GOPATH/src/$APP_PATH/vendor/

# Add Nginx frontend host
RUN cp $GOPATH/src/$APP_PATH/docker/nginx-revel.vhost /etc/nginx/conf.d/default.conf

# Setup Nginx
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 3/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 3;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
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
