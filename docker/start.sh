#!/bin/bash

# Configure App (MySQL Password, Database setup and Config setup)
if [ ! -f /app-configured ]; then
	# General MySQL config changes
	sed -i -e "s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

	# Setup MySQL database folder if it is not already populated
	if [ ! -f /var/lib/mysql/ibdata1 ]; then
		mysql_install_db
	fi

	/usr/bin/mysqld_safe &
	sleep 10s

	# Generate new MySQL root password
	MYSQL_PASSWORD=`pwgen -c -n -1 12`
	echo mysql root password: $MYSQL_PASSWORD

	# Set MySQL root password
	mysqladmin -u root password $MYSQL_PASSWORD

	# Create required App databases
	mysqladmin -u root -p$MYSQL_PASSWORD CREATE app
	mysqladmin -u root -p$MYSQL_PASSWORD CREATE app_dev

	killall mysqld

	# Grab app.conf file
	APP_CONF_FILE=$GOPATH/src/$APP_PATH/conf/app.conf
	if [ ! -f $GOPATH/src/$APP_PATH/conf/app.conf ]; then
		APP_CONF_FILE=$GOPATH/src/$APP_PATH/conf/app.conf.default
	fi

	# Ensure app secret is set
	sed -i "s/<app_secret_please_change_me>/`pwgen -c -n -1 65`/g" $APP_CONF_FILE

	# Add MySQL password to app.conf file
	sed -i "s/user:pass@tcp(localhost:3306)\/app_dev?charset=utf8/root:$MYSQL_PASSWORD@tcp(localhost:3306)\/app_dev?charset=utf8/g" $APP_CONF_FILE
	sed -i "s/user:pass@tcp(localhost:3306)\/app?charset=utf8/root:$MYSQL_PASSWORD@tcp(localhost:3306)\/app?charset=utf8/g" $APP_CONF_FILE

	if [ $APP_CONF_FILE == $GOPATH/src/$APP_PATH/conf/app.conf.default ]; then
		mv $APP_CONF_FILE $GOPATH/src/$APP_PATH/conf/app.conf
	fi

	touch /app-configured
	sleep 10s

fi

# start all the services (in long-running nodaemon mode)
/usr/local/bin/supervisord -n