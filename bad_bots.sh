#!/bin/bash
#Setting Help text block
#Start block to check which webservice is running
IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
echo "Checking webservice"
WEBSERVICE=$(curl -skIL https://$IP |grep -i "server:" | awk {'print $2'})
if [ -z "${WEBSERVICE}" ]; then
	echo "This has no running web service, are you sure this is a webserver?"
	exit 0
fi
	

echo "Webservice is $WEBSERVICE"
sleep 1
#End block to check which webservice is running

#Start block to check if the server is running a Panel
echo "Checking if cPanel or Plesk"
if [[ ! -f /sbin/plesk && -f /usr/local/cpanel/cpanel ]]; then
	PANEL="cPanel"
	echo "Server is running $PANEL."
elif [[ -f /sbin/plesk && ! -f /usr/local/cpanel/cpanel ]]; then
	PANEL="Plesk"
	echo "Server is running $PANEL."
else
	PANEL="none"
	echo "Server is not running a panel"
fi 
sleep 1
#End block to check if the server is running a Panel


if [[ "$WEBSERVICE" =~ nginx  &&  "$PANEL" =~ Plesk ]]; then
	#Start block to check if script has been run before
	if [ -f /etc/nginx/ans_badbots.conf ]; then
		echo "Script has already been run, please add new bots to /etc/nginx/ans_badbots.conf"
		exit 0
	#End block to check if script has been run before
	
	#Start block to implement bad bot block on Plesk with Nginx
	echo "Proceeding with bad bot set up for $PANEL running $WEBSERVICE"
	else 
		echo "Creating bad bots conf file at /etc/nginx/ans_badbots.conf"
		touch /etc/nginx/ans_badbots.conf
		echo -e "#ANS Serverwide bad bot block
		if (\$http_user_agent ~* AspiegelBot|aspiegel|PetalBot|baidu|ahrefs|semrush|xovibot|360Spider|dotbot|genieo|megaindex\.ru|vagabondo|yandexbot|yelpspider|fatbot|tineye|blexbot|ascribebot|ia_archiver|moatbot|mixrankbot|orangebot|yoozbot|mj12bot|paperlibot|showyoubot|grapeshot|WeSee|haosouspider|spider|lexxebot|nutch) 
{
		return 403;
  }" > /etc/nginx/ans_badbots.conf
		sleep 2
		echo "Performing nginx config test"
		if nginx -t > /dev/null 2>&1 ; then
			#Start block to update vhost template and apply
			echo "Updating vhost template at /opt/psa/admin/conf/templates/default/domain/nginxDomainVirtualHost.php"
			sed -i '/server {/a include \/etc\/nginx\/ans_badbots.conf;' /opt/psa/admin/conf/templates/default/domain/nginxDomainVirtualHost.php
			echo "Rebuilding vhost configuration"
			plesk repair web -domains-only -y
			sleep 3
			if nginx -t > /dev/null 2>&1 ; then
				echo "Bad bot setup complete"
			#End block to update vhost template and apply
			else
			#Start block to clean up vhost template change if nginx config test fails
				echo "nginx test failed post vhost edit failed, undoing changes"
				echo "reverting template modifications"
				sed -i '/^include \/etc\/nginx\/ans_badbots.conf;/d' /opt/psa/admin/conf/templates/default/domain/nginxDomainVirtualHost.php
				echo "removing bad bots file"
				rm -f /etc/nginx/ans_badbots.conf
				echo "Rebuilding vhost configuration"
				plesk repair web -domains-only -y
				sleep 3
			fi
			#End block to clean up vhost template change if nginx config test fails
		else
			#Start block to clean up if nginx test fails after file creation
			echo "Nginx test failed post file bot file creation at /etc/nginx/ans_badbots.conf, please check journal logs for nginx to see why"
			echo "Cleaning up /etc/nginx/ans_badbots.conf"
			rm -f /etc/nginx/ans_badbots.conf
			#End block to clean up if nginx test fails after file creation
		fi
	fi
	#End block to implement bad bot block on Plesk with Nginx

elif [[ "$WEBSERVICE" =~ Apache  &&  "$PANEL" =~ Plesk ]]; then
	#Start block to check if script has been run before
	if [ -f /etc/apache2/conf-enabled/zz011_ans_bad_bots.conf ]; then
		echo "Script has already been run, please add new bots to /etc/apache2/conf-enabled/zz011_ans_bad_bots.conf"
		exit 0
	#End block to check if script has been run before
	
	#Start block to implement bad bot block on Plesk with Apache
	echo "Proceeding with bad bot set up for $PANEL running $WEBSERVICE"
	else
		echo "Setting up bad bots block for Apache"
		echo "Creating bad bots conf file at /etc/apache2/conf-enabled/zz011_ans_bad_bots.conf"
		touch /etc/apache2/conf-enabled/zz011_ans_bad_bots.conf
		echo -e '<Directory "/var/www/vhosts">
SetEnvIfNoCase User-Agent "360Spider" bad_bots 
SetEnvIfNoCase User-Agent "RSurf15a" bad_bots 
SetEnvIfNoCase User-Agent "SSurf15a" bad_bots 
SetEnvIfNoCase User-Agent "VadixBot" bad_bots 
SetEnvIfNoCase User-Agent "gptbot" bad_bots 
SetEnvIfNoCase User-Agent "WeSee" bad_bots 
SetEnvIfNoCase User-Agent "ahrefs" bad_bots 
SetEnvIfNoCase User-Agent "amazonbot" bad_bots 
SetEnvIfNoCase User-Agent "ascribebot" bad_bots 
SetEnvIfNoCase User-Agent "baidu" bad_bots 
SetEnvIfNoCase User-Agent "Bytespider" bad_bots 
SetEnvIfNoCase User-Agent "blexbot" bad_bots 
SetEnvIfNoCase User-Agent "claudebot" bad_bots 
SetEnvIfNoCase User-Agent "dotbot" bad_bots 
SetEnvIfNoCase User-Agent "fatbot" bad_bots 
SetEnvIfNoCase User-Agent "genieo" bad_bots 
SetEnvIfNoCase User-Agent "grapeshot" bad_bots 
SetEnvIfNoCase User-Agent "haosouspider" bad_bots 
SetEnvIfNoCase User-Agent "ia_archiver" bad_bots 
SetEnvIfNoCase User-Agent "lexxebot" bad_bots 
SetEnvIfNoCase User-Agent "megaindex\.ru" bad_bots 
SetEnvIfNoCase User-Agent "mixrankbot" bad_bots 
SetEnvIfNoCase User-Agent "MJ12bot" bad_bots 
SetEnvIfNoCase User-Agent "moatbot" bad_bots 
SetEnvIfNoCase User-Agent "nutch" bad_bots 
SetEnvIfNoCase User-Agent "orangebot" bad_bots 
SetEnvIfNoCase User-Agent "paperlibot" bad_bots 
SetEnvIfNoCase User-Agent "petalbot" bad_bots 
SetEnvIfNoCase User-Agent "semrush" bad_bots 
SetEnvIfNoCase User-Agent "showyoubot" bad_bots 
SetEnvIfNoCase User-Agent "sogou" bad_bots 
SetEnvIfNoCase User-Agent "spider" bad_bots 
SetEnvIfNoCase User-Agent "tineye" bad_bots 
SetEnvIfNoCase User-Agent "vagabondo" bad_bots 
SetEnvIfNoCase User-Agent "xovibot" bad_bots 
SetEnvIfNoCase User-Agent "yandexbot" bad_bots 
SetEnvIfNoCase User-Agent "yelpspider" bad_bots 
SetEnvIfNoCase User-Agent "yoozbotAspiegelBot" bad_bots 
SetEnvIfNoCase User-Agent "aspiegel" bad_bots 
SetEnvIfNoCase User-Agent "AhrefsBot" bad_bots 
SetEnvIfNoCase User-Agent "MJ12" bad_bots 
SetEnvIfNoCase User-Agent "Bytedance" bad_bots 
SetEnvIfNoCase User-Agent "fidget-spinner-bot" bad_bots 
SetEnvIfNoCase User-Agent "EmailCollector" bad_bots 
SetEnvIfNoCase User-Agent "WebEMailExtrac" bad_bots 
SetEnvIfNoCase User-Agent "seocompany" bad_bots 
SetEnvIfNoCase User-Agent "LieBaoFast" bad_bots 
SetEnvIfNoCase User-Agent "SEOkicks" bad_bots 
SetEnvIfNoCase User-Agent "Uptimebot" bad_bots 
SetEnvIfNoCase User-Agent "Cliqzbot" bad_bots 
SetEnvIfNoCase User-Agent "ssearch_bot" bad_bots 
SetEnvIfNoCase User-Agent "domaincrawler" bad_bots 
SetEnvIfNoCase User-Agent "spot" bad_bots 
SetEnvIfNoCase User-Agent "DigExt" bad_bots 
SetEnvIfNoCase User-Agent "Sogou" bad_bots 
SetEnvIfNoCase User-Agent "majestic12" bad_bots 
SetEnvIfNoCase User-Agent "80legs" bad_bots 
SetEnvIfNoCase User-Agent "SISTRIX" bad_bots 
SetEnvIfNoCase User-Agent "HTTrack" bad_bots 
SetEnvIfNoCase User-Agent "Ezooms" bad_bots 
SetEnvIfNoCase User-Agent "CCBot" bad_bots
<RequireAll>
Require all granted
Require not env bad_bots
</RequireAll>
</Directory>' > /etc/apache2/conf-enabled/zz011_ans_bad_bots.conf
		echo "Performing Apache config test"
		if apachectl -t > /dev/null 2>&1 ; then
			echo "Config test successful, restarting apache"
			plesk bin settings --set restart_apache_gracefully=true \\ Set apache to graceful restart so less disruption
			systemctl restart apache2 > /dev/null 2>&1
		else
			#Start block to clean up if apache fails config test
			echo "Apache failed configuration test after bad bot creation, cleaning up."
			echo "Removing /etc/apache2/conf-enabled/zz011_ans_bad_bots.conf"
			rm -f /etc/apache2/conf-enabled/zz011_ans_bad_bots.conf
			#End block to clean up if apache fails config test
		fi

	fi
	#End block to implement bad bot block on Plesk with Apache
	
elif [[ "$WEBSERVICE" =~ Apache || "$WEBSERVICE" =~ nginx  &&  "$PANEL" =~ cPanel ]]; then
	#Start block to check if script has been run before
	if [ $(grep -ic "Require not env bad_bots" /etc/apache2/conf.d/includes/pre_main_global.conf) -gt 0 ]; then
		echo "Script has already been run, please add new bots to /etc/apache2/conf.d/includes/pre_main_global.conf"
		exit 0
	#End block to check if script has been run before
	
	#Start block to implement bad bot block on cPanel with Apache
	echo "Proceeding with bad bot set up for $PANEL running $WEBSERVICE"
	else 
		echo "creating backup of conf file"
		cp /etc/apache2/conf.d/includes/pre_main_global.conf /etc/apache2/conf.d/includes/pre_main_global.conf.bak
		echo "Setting up bad bots block for Apache"
		echo "Adding to /etc/apache2/conf.d/includes/pre_main_global.conf"
		echo -e '<Directory "/home">
SetEnvIfNoCase User-Agent "360Spider" bad_bots 
SetEnvIfNoCase User-Agent "RSurf15a" bad_bots 
SetEnvIfNoCase User-Agent "SSurf15a" bad_bots 
SetEnvIfNoCase User-Agent "VadixBot" bad_bots 
SetEnvIfNoCase User-Agent "gptbot" bad_bots 
SetEnvIfNoCase User-Agent "WeSee" bad_bots 
SetEnvIfNoCase User-Agent "ahrefs" bad_bots 
SetEnvIfNoCase User-Agent "amazonbot" bad_bots 
SetEnvIfNoCase User-Agent "ascribebot" bad_bots 
SetEnvIfNoCase User-Agent "baidu" bad_bots 
SetEnvIfNoCase User-Agent "Bytespider" bad_bots 
SetEnvIfNoCase User-Agent "blexbot" bad_bots 
SetEnvIfNoCase User-Agent "claudebot" bad_bots 
SetEnvIfNoCase User-Agent "dotbot" bad_bots 
SetEnvIfNoCase User-Agent "fatbot" bad_bots 
SetEnvIfNoCase User-Agent "genieo" bad_bots 
SetEnvIfNoCase User-Agent "grapeshot" bad_bots 
SetEnvIfNoCase User-Agent "haosouspider" bad_bots 
SetEnvIfNoCase User-Agent "ia_archiver" bad_bots 
SetEnvIfNoCase User-Agent "lexxebot" bad_bots 
SetEnvIfNoCase User-Agent "megaindex\.ru" bad_bots 
SetEnvIfNoCase User-Agent "mixrankbot" bad_bots 
SetEnvIfNoCase User-Agent "MJ12bot" bad_bots 
SetEnvIfNoCase User-Agent "moatbot" bad_bots 
SetEnvIfNoCase User-Agent "nutch" bad_bots 
SetEnvIfNoCase User-Agent "orangebot" bad_bots 
SetEnvIfNoCase User-Agent "paperlibot" bad_bots 
SetEnvIfNoCase User-Agent "petalbot" bad_bots 
SetEnvIfNoCase User-Agent "semrush" bad_bots 
SetEnvIfNoCase User-Agent "showyoubot" bad_bots 
SetEnvIfNoCase User-Agent "sogou" bad_bots 
SetEnvIfNoCase User-Agent "spider" bad_bots 
SetEnvIfNoCase User-Agent "tineye" bad_bots 
SetEnvIfNoCase User-Agent "vagabondo" bad_bots 
SetEnvIfNoCase User-Agent "xovibot" bad_bots 
SetEnvIfNoCase User-Agent "yandexbot" bad_bots 
SetEnvIfNoCase User-Agent "yelpspider" bad_bots 
SetEnvIfNoCase User-Agent "yoozbotAspiegelBot" bad_bots 
SetEnvIfNoCase User-Agent "aspiegel" bad_bots 
SetEnvIfNoCase User-Agent "AhrefsBot" bad_bots 
SetEnvIfNoCase User-Agent "MJ12" bad_bots 
SetEnvIfNoCase User-Agent "Bytedance" bad_bots 
SetEnvIfNoCase User-Agent "fidget-spinner-bot" bad_bots 
SetEnvIfNoCase User-Agent "EmailCollector" bad_bots 
SetEnvIfNoCase User-Agent "WebEMailExtrac" bad_bots 
SetEnvIfNoCase User-Agent "seocompany" bad_bots 
SetEnvIfNoCase User-Agent "LieBaoFast" bad_bots 
SetEnvIfNoCase User-Agent "SEOkicks" bad_bots 
SetEnvIfNoCase User-Agent "Uptimebot" bad_bots 
SetEnvIfNoCase User-Agent "Cliqzbot" bad_bots 
SetEnvIfNoCase User-Agent "ssearch_bot" bad_bots 
SetEnvIfNoCase User-Agent "domaincrawler" bad_bots 
SetEnvIfNoCase User-Agent "spot" bad_bots 
SetEnvIfNoCase User-Agent "DigExt" bad_bots 
SetEnvIfNoCase User-Agent "Sogou" bad_bots 
SetEnvIfNoCase User-Agent "majestic12" bad_bots 
SetEnvIfNoCase User-Agent "80legs" bad_bots 
SetEnvIfNoCase User-Agent "SISTRIX" bad_bots 
SetEnvIfNoCase User-Agent "HTTrack" bad_bots 
SetEnvIfNoCase User-Agent "Ezooms" bad_bots 
SetEnvIfNoCase User-Agent "CCBot" bad_bots
<RequireAll>
Require all granted
Require not env bad_bots
</RequireAll>
</Directory>' >> /etc/apache2/conf.d/includes/pre_main_global.conf
		echo "Performing Apache config test"
		if apachectl -t > /dev/null 2>&1 ; then
			echo "Config test successful, restarting apache"
			/scripts/restartsrv_apache > /dev/null 2>&1
		else
			#Start block to clean up if apache fails config test
			echo "Apache failed configuration test after bad bot creation, cleaning up."
			echo "Restoring backup of /etc/apache2/conf.d/includes/pre_main_global.conf"
			mv /etc/apache2/conf.d/includes/pre_main_global.conf.bak /etc/apache2/conf.d/includes/pre_main_global.conf
			#End block to clean up if apache fails config test
		fi

	fi
	#End block to implement bad bot block on Cpanel with Apache
	

elif [[ "$WEBSERVICE" =~ Apache  &&  "$PANEL" =~ none ]]; then
	echo "This script is not designed to be run on the current server, this script is designed for use on Plesk or cPanel servers running nginx or Apache as the primary web server."
	echo "As this server is not running a panel with $WEBSERVICE, you may be able to manually implement this by creating a configuration manually in /etc/httpd/conf.d/ or /etc/apache2/conf.d"
elif [[ "$WEBSERVICE" =~ nginx  &&  "$PANEL" =~ none ]]; then
	echo "This script is not designed to be run on the current server, this script is designed for use on Plesk servers running nginx or Apache as the primary web server or cPanel servers running Apache."
	echo "As this server is not running a panel with $WEBSERVICE , it is possible this is a Magento stack, if so you can control bad bots in the vhost configuration file.  If this is not a Magento stack then it will require manual processing"
else
	echo "This script is not designed to be run on the current server, this script is designed for use on Plesk servers running nginx or Apache as the primary web server or cPanel servers running Apache."
	echo "This server does not match any known setup, it runs no panel with $WEBSERVICE."
fi
