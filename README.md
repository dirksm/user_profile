# Spring MVC Web Application with Bootstrap For Managing Users
This is an example of the web application using the following components:
* [Spring MVC](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/mvc.html)
* [Maven](http://maven.apache.org/)
* [Bootstrap 3](http://getbootstrap.com/)
* [NiceAdmin](http://bootstraptaste.com/nice-admin-bootstrap-admin-html-template/) for the front-end look and feel.
* [Vagrant](http://www.vagrantup.com)
* [MailCatcher](https://mailcatcher.me)

## Steps to install
* Ensure VirtualBox(4.3) and Vagrant are installed on your workstation.
* Clone this repository.
* Execute ```vagrant up```
* Install apache tomcat version 7.
* Import this project into [Spring Tool Suite (STS)](https://spring.io/tools).
* Right-click on project in STS and select Maven->Update project.
* Add project to Tomcat server
* Start server.  Application should be available at [http://localhost:8080/userprofile/](http://localhost:8080/userprofile/).
* Log in as either 'testadmin' or 'testuser' with password of 'abc123'

## Steps to deploy
This application can be deployed to a war file and deployed to a Tomcat or similar JEE web container.  
To deploy:
* Right click on the project and select Run As -> Maven build...
* Enter 'clean install -Denvironment=production' in the goals field.  
* Click 'Apply' and 'Run'
* The deployment artifact will be available in the target folder.

## Database access
The database is on the Vagrant box and can be accessible by the IP address you set in the Vagrantfile (default to 192.168.33.21).
You can access PHPMyAdmin from [http://192.168.33.21/phpmyadmin](http://192.168.33.21/phpmyadmin).  The username is root and the password is the value set by the ```DBROOTPASSWORD``` variable below.  The database is name ```user_profile```.

## Mail server development
This project uses [MailCatcher](https://mailcatcher.me) to use as a development email SMTP server.  This allows the developer to test email functionality without having to accidentally send emails to actual users.  The current setup uses Ruby version 1.9.x but MailCatcher needs
version > 2.0.x.  There are some workarounds in the batch file to ensure that MailCatcher is set up correctly.  To access the web interface,
navigate to http://192.168.33.21/mailcatcher. The IP address may change depending on your IP setting for your private network in the Vagrantfile
file.

## Vagrant setup for Ubuntu 14.04, Apache, MySQL, and phpMyAdmin

### Description
This project is a boilerplate for setting up a web server using [Vagrant](http://www.vagrantup.com).  This requires the installation of Vagrant
and Oracle's Virtual Box (Version 4.3 is that latest version to work with Vagrant).

More information can be found on the [Vagrant - Getting Started](https://www.vagrantup.com/docs/getting-started/) web page.

The Vagrantfile:
* sets up a Ubuntu 14.04 LTS 32bit box
* makes the box accessable by the host at IP ```192.168.33.21```
* syncs the ```/sql``` folder with ```/vagrant/sql``` inside the box (permanently, in both directions)
* automatically perform all the commands in bootstrap.sh directly after setting up the box for the first time

bootstrap.sh holds your chosen password and your chosen project folder name and does this:

* updates and upgrades Ubuntu 14.04 to the latest version and updates
* creates the sql folder inside /vagrant/sql
* installs Apache 2.4, PHP 5.5, MySQL, PHPMyAdmin
* sets the pre-chosen password for MySQL and PHPMyAdmin
* activates mod_rewrite and add AllowOverride All to the vhost settings
* fixes the missing mcrypt error in phpmyadmin

### Example
* Clone this project to your workspace. 
* Modify the ```DBPASSWORD``` variable in ```bootstrap.sh``` to your chosen root password. 
* Modify the ```DBROOTPASSWORD``` variable in ```bootstrap.sh``` to your chosen project name. 
* Modify the ```config.vm.network "private_network", ip: "192.168.33.21"``` to your chosen IP address.
* Make sure the IP address you choose is outside your network gateway (If your router address is 192.168.1.1, use an address outside of 192.168.1.*).

To create a new virtual machine environment run:
```
vagrant up
```

Make sure you already have the ubuntu/trusty32 loaded.  If not do
```
vagrant box add ubuntu/trusty32
```

###PostScript
To safely stop the box simply run the command:
```vagrant halt```

To destroy the box run:
```vagrant destroy```

If you modify ```bootstrap.sh``` you can reprovision the box by running:
```vagrant provision```