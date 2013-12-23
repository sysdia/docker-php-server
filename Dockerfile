FROM ubuntu:12.04

#Install dependencies
RUN apt-get -q -y update
RUN apt-get install -q -y wget curl build-essential git apache2 php5 libapache2-mod-php5 git php5-dev python-software-properties openssl openssh-server whois

RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list
RUN apt-get -q -y update
RUN apt-get install -q -y msmtp ca-certificates

#Set up SSH login
RUN mkdir /var/run/sshd
RUN adduser --home /home/remoteuser --shell /bin/bash --disabled-login remoteuser

#Set up sendmail for PHP
RUN touch /etc/msmtprc

RUN mkdir -p /var/log/msmtp
RUN chown www-data:adm /var/log/msmtp

RUN touch /etc/logrotate.d/msmtp
RUN rm /etc/logrotate.d/msmtp
RUN echo "/var/log/msmtp/*.log {\n rotate 12\n monthly\n compress\n missingok\n notifempty\n }" > /etc/logrotate.d/msmtp

RUN sed -i 's/;sendmail_path\s=.*/sendmail_path = \/usr\/bin\/msmtp -t/' /etc/php5/apache2/php.ini

#Initialise instance
ADD run.sh /usr/local/bin/run
RUN chmod +x /usr/local/bin/run


#Stop cacheing - totally not a hack
ADD . .

#GENERATE A PASSWORD
RUN export REMOTEUSER_PASSWD=`tr -dc "[:alpha:]" < /dev/urandom | head -c 8`; export REMOTEUSER_PASSWD_HASH=`mkpasswd $REMOTEUSER_PASSWD`; usermod --password $REMOTEUSER_PASSWD_HASH remoteuser; echo "ssh with: ssh remoteuser@localhost and password: $REMOTEUSER_PASSWD"

EXPOSE 22 80

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

CMD ["/usr/local/bin/run"]
