#!/bin/sh

# Config Settings
prodhosts="web01 web02"
dbhosts="mysql01 mysql02"
mysqluser="dumpuser"
mysqlpass="abc123"

choseweb=0

if [ `echo $1 | wc -m` -lt 2 ]
then
	echo "Usage: deploy_to_stage <website>"
fi

if [ `echo $1 | grep -c web1` -gt 0 ]
then
	database="web1db"
	dboptions=""
	webdir="web1"
	extra=""
	echo "Deploying web1 Website to Production"
	choseweb=1
fi

if [ `echo $1 | grep -c web2` -gt 0 ]
then
	database="web2"
	dboptions=""
	webdir="web2"
        extra=""
	echo "Deploying  web2 Website to Production"
	choseweb=1
fi

if [ `echo $1 | grep -c web3` -gt 0 ]
then
	database="web3"
	dboptions="--ignore-table=web3.cw_users --ignore-table=web3.cw_usergroup"
	webdir="web3"
        extra=""
	echo "Deploying web  Website to Production"
	choseweb=1
fi

if [ `echo $1 | grep -c mweb` -gt 0 ]
then
        database="web_mob"
        dboptions=""
	webdir="mweb"
        extra=""
        echo "Deploying mweb Mobile Website to Production"
        choseweb=1
fi



if [ $choseweb -lt 1 ]
then
	echo "Please choose a valid website to deploy to Production"
	echo "Valid websites are web1, web2, web3 and mweb "
	echo "For example deploy_to_stage web1"
	echo "Will deploy the web1 website to Production"
	exit;
fi

# Delete any old database dumps
rm -rf /tmp/dbdumps

# Create the dump dir
mkdir -p /tmp/dbdumps

mysqldump --user=$mysqluser --password=$mysqlpass $database $dboptions | gzip > /tmp/dbdumps/$database.sql.gz






for prodhost in $prodhosts
do
	/usr/bin/rsync -avzH --delete /var/www/$webdir/ $prodhost:/var/www/$webdir/
done

for dbhost in $dbhosts
do
	zcat /tmp/dbdumps/$database.sql.gz | mysql --host=$dbhost --port=3306 --user=$mysqluser --password=$mysqlpass $database
done



#  standard server init script  stop,start,restart init.d script OR   ' bundle exec rackup  -p 80 '  which will need proccess checking, assume diligence and  package applications are pre installed  check and verify.
for prodhost in $prodhosts
do
        sudo su httpd -c ssh $prodhosts /etc/init.d/$webdir restart &&  bundle install /var/www/$webdir/
done

for prodhost  in $prodhosts
do
	lsof -i :9292

done
echo " your a sysadmin check its running " 

for prodhosts in $prodhosts
do
	curl http://$prodhosts
done
