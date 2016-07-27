#!/usr/bin/env bash

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