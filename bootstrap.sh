#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
DBROOTPASSWORD='12345678'
DBPASSWORD='12345678'
DBUSERNAME='userprofile'
DATABASE='userprofile'

# update / upgrade
echo updating os
sudo apt-get update > /dev/null

# install apache 2.5 and php 5.5
echo installing apache
sudo apt-get install -y apache2 > /dev/null
echo installing php5
sudo apt-get install -y php5 > /dev/null

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBROOTPASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBROOTPASSWORD"
echo installing mysql-server
sudo apt-get -y install mysql-server > /dev/null
echo installing php5-mysql
sudo apt-get install php5-mysql > /dev/null

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBROOTPASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBROOTPASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBROOTPASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
echo installing phpmyadmin
sudo apt-get -y install phpmyadmin > /dev/null

# Setup database
echo creating database $DATABASE
mysql -uroot -p$DBROOTPASSWORD -e "CREATE DATABASE $DATABASE;"

# Make MySQL external accessible
echo `mysql -uroot -p$DBROOTPASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '$DBUSERNAME'@'%' IDENTIFIED BY '$DBPASSWORD';"`
echo `mysql -uroot -p$DBROOTPASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '$DBUSERNAME'@'localhost' IDENTIFIED BY '$DBPASSWORD';"`
echo `mysql -uroot -p$DBROOTPASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$DBROOTPASSWORD';"`
echo `mysql -uroot -p$DBROOTPASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$DBROOTPASSWORD';"`
sed -i 's/^bind-address/#bind-address/' /etc/mysql/my.cnf
sed -i 's/^skip-external-locking/#skip-external-locking/' /etc/mysql/my.cnf
sudo service mysql restart

# Import bootstrap SQL
echo importing database objects
mysql -uroot -p$DBROOTPASSWORD $DATABASE < /vagrant/sql/create.sql

# enable mod_rewrite
sudo a2enmod rewrite

# activate mcrypt
cd /etc/php5/mods-available
sudo php5enmod mcrypt

# restart apache
sudo service apache2 restart

##-------- Start of MailCatcher install ---------##
# execute script to install mailcatcher
# install mail-catcher SMTP server
echo installing build-essential
sudo apt-get install -y build-essential
 
# install mailcatcher (http://mailcatcher.me/)
echo installing ruby and libsqlite3-dev
sudo apt-get install -y ruby-dev libsqlite3-dev
echo installing mime-types
sudo gem install -y mime-types --version "< 3"
echo installing mail-catcher
sudo gem install -y --conservative mailcatcher
# enable apache proxy modules to configure a reverse proxy to mailcatchers webfrontend
sudo a2enmod proxy proxy_http proxy_wstunnel
 
# replace sendmail path in php.ini with catchmail path
CATCHMAIL="$(which catchmail)"
sudo sed -i "s|;sendmail_path\s=.*|sendmail_path = $CATCHMAIL|" /etc/php5/apache2/php.ini

#execute mailcatcher
echo starting mailcatcher
mailcatcher --smtp-ip=0.0.0.0
 
# setup hosts file 
echo modifying vhosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf

        ProxyRequests Off
        ProxyPass /mailcatcher http://localhost:1080
        ProxyPass /assets http://localhost:1080/assets
        ProxyPass /messages http://localhost:1080/messages

</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# restart apache
sudo service apache2 restart
##-------- End of MailCatcher install ---------##
