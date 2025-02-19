#!/bin/bash
#Setting Help text block
if [[ $1 == "-h" || $1 == "--help" ]]; then
	echo "Usage: $(basename $0) nginx/apache"
	echo "Options:"
	echo "  -h, --help                    Display this help message"
	echo "  nginx                         Use this option if the server runs nginx on port 443"
	echo "  apache                        Use this option if the server runs apache on port 443"
	exit 0

elif [[ $1 == "nginx" ]]; then
	if [ ! -f /etc/nginx/badbots.conf ]; then
		echo "Setting up bad bots block for nginx"
		echo "Creating bad bots conf file"
		touch /etc/nginx/badbots.conf
		echo -e "#ANS Serverwide bad bot block
		if (\$http_user_agent ~* AspiegelBot|aspiegel|PetalBot|baidu|ahrefs|semrush|xovibot|360Spider|dotbot|genieo|megaindex\.ru|vagabondo|yandexbot|yelpspider|fatbot|tineye|blexbot|ascribebot|ia_archiver|moatbot|mixrankbot|orangebot|yoozbot|mj12bot|paperlibot|showyoubot|grapeshot|WeSee|haosouspider|spider|lexxebot|nutch) 
{
        return 403;
  }" > /etc/nginx/badbots.conf
		sleep 2
		echo "Performing nginx config test"
		if nginx -t > /dev/null 2>&1 ; then
			echo "Updating vhost template"
			sed -i '/server {/a include /etc/nginx/badbots.conf;' /opt/psa/admin/conf/templates/default/domain/nginxDomainVirtualHost.php
			echo "Rebuilding vhost configuration"
			plesk repair web -domains-only -y
			sleep 3
			if nginx -t > /dev/null 2>&1 ; then
				echo "Bad bot setup complete"
			else
				echo "nginx test failed post vhost edit failed, undoing changes"
				rm -f /etc/nginx/bad_bots.conf
				sed -i '/^include \/etc\/nginx\/badbots.conf;/d' /opt/psa/admin/conf/templates/default/domain/nginxDomainVirtualHost.php
				plesk repair web -domains-only -y
				sleep 3
			fi
		else
			echo "Nginx test failed post file bot file creation."
			echo "Cleaning up failed attempt"
			rm -f /etc/nginx/bad_bots.conf
		fi
	else
		echo "Script has already been run, please add new bots to /etc/nginx/badbots.conf"
	fi

elif [[ $1 == "apache" ]]; then
	if [ ! -f /etc/apache2/conf-enabled/zz011_bad_bots.conf ]; then
		echo "Setting up bad bots block for Apache"
		echo "Creating bad bots conf file"
		touch /etc/apache2/conf-enabled/zz011_bad_bots.conf
		echo -e "<Directory "/var/www/vhosts">
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
SetEnvIfNoCase User-Agent "yoozbot" bad_bots
<RequireAll>
Require all granted
Require not env bad_bots
</RequireAll>
</Directory>" > /etc/apache2/conf-enabled/zz011_bad_bots.conf
		echo "Performing Apache config test"
		if apachectl -t > /dev/null 2>&1 ; then
			echo "Config test successful, restarting apache"
			plesk bin settings --set restart_apache_gracefully=true \\ Set apache to graceful restart
			systemctl restart apache2 > /dev/null 2>&1
		else
			echo "!!! WARNING !!! apache config test failed"
			echo "Cleaning up failed attempt"
			rm -f /etc/apache2/conf-enabled/zz011_bad_bots.conf
		fi
	else
		echo "Script has already been run, please add new bots to /etc/apache2/conf-enabled/zz011_bad_bots.conf"
	fi

else
	echo "Please provide valid option, you can use -h for options"
fi
