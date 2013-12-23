#!/bin/bash

source /etc/environment
/usr/sbin/sshd -D

/usr/sbin/apache2 -D FOREGROUND