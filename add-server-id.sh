#!/bin/bash -e
OCTETS=(`hostname -i | tr -s '.' ' '`)

MYSQL_SERVER_ID=`expr ${OCTETS[2]} \* 256 + ${OCTETS[3]}`
echo "server-id=$MYSQL_SERVER_ID" >> /etc/mysql/mysql.conf.d/mysqld.cnf

if [ -z "$MYSQL_MASTER" ]; then
    echo "read_only=1" >> /etc/mysql/mysql.conf.d/mysqld.cnf
    echo "log-slave-updates" >> /etc/mysql/mysql.conf.d/mysqld.cnf
    echo "slave-skip-errors = all" >> /etc/mysql/mysql.conf.d/mysqld.cnf
    echo "Slave is now read-only"
fi