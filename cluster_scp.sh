#!/bin/bash
clusterhosts="cluser-server01 cluser-server02"
filename=$1
path=`pwd`

for host in $clusterhosts
do
	sudo su httpd -c "scp -rv $path/$filename $host:$path/"
done
