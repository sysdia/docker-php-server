#!/bin/bash
/usr/sbin/sshd -D &
/usr/sbin/apache2 -D FOREGROUND
