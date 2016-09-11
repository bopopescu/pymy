#!/usr/bin/env bash
#################################################
# Author: Rhys Campbell                         #
# Created: 2016-06-12                           #
# Description: Creates and configures a MariaDB #
# cluster. Uses the my tool from...             #
# https://github.com/mathnode/mim               #
# Developed on a Mac but aid to support Linux   #
# Not yet fully functional.                     #
#################################################

set -e;
set -o pipefail;
#set -u;

if [ $(uname) == "Darwin" ]; then
	MYSQL_RELEASE="http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.13-osx10.11-x86_64.tar.gz"
	MARIADB_RELEASE=MYSQL_RELEASE;
	echo "Note: No currently available tar release for MariaDB on OS X. Using MySQL."
elif [ $(uname) == "Linux" ]; then
	MYSQL_RELEASE="http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.13-linux-glibc2.5-x86_64.tar"
	MARIADB_RELEASE="https://downloads.mariadb.org/interstitial/mariadb-10.1.14/bintar-linux-x86_64/mariadb-10.1.14-linux-x86_64.tar.gz"
else
	echo "Unsupported Operating System";
	exit 1;
fi;

SELECTED_RELEASE="$MYSQL_RELEASE";

function myc_have_my
{
	if [ ! `which my` ]; then
		echo "my not in path. Get it from https://github.com/mathnode/mim";
		exit 1;
	fi;
}

function myc_is_my_setup_done
{
	S=-1
	if [ -d "~/tmp_mycluster/mim-databases/configs" ] && [ -d "~/tmp_mycluster/mim-databases/templates" ] && [ -d "~/tmp_mycluster/mim-databases/data" ]; then
		S=0;
	else
		S=1;
	fi;
	return ${S};
}

function myc_get_templates
{
	for url in https://raw.githubusercontent.com/mathnode/mim/master/templates/client-settings https://raw.githubusercontent.com/mathnode/mim/master/templates/common-settings https://raw.githubusercontent.com/mathnode/mim/master/templates/mariadb10 https://raw.githubusercontent.com/mathnode/mim/master/templates/olap https://raw.githubusercontent.com/mathnode/mim/master/templates/oltp-acid-transactional https://raw.githubusercontent.com/mathnode/mim/master/templates/utf8-settings
	do
		wget --directory-prefix="$MIMHOME/templates" "$url";
	done;
	
}

function myc_setup_env
{
	myc_have_my;
	export MIMBINARIES=~/tmp_mycluster/mim-binaries;
	export MIMHOME=~/tmp_mycluster/mim-databases;
	mkdir -p ~/tmp_mycluster/mim-binaries;
	mkdir -p ~/tmp_mycluster/mim-databases;
	if [ ! myc_is_my_setup_done ]; then
		cp -n ~/tmp_mycluster/mim-databases/templates/* ~/tmp_mycluster/mim-databases/configs
	fi;
}

# mysql_install_db changed from a script to a binary so the path changed
# from scripts/mysql_install_db to bin/mysql_install_db untar and hotlink
# the mysql_install_db binary if needed
function myc_prepare_release
{
	RELEASE=$1;
	FILENAME=$(basename "$RELEASE")
	DIR_NAME="${FILENAME%.*}";
	DIR_NAME="${DIR_NAME%.*}"; # because this is usually a .tar.gz
	if [ ! -d "$MIMBINARIES/$DIR_NAME/scripts" ]; then
			echo "$MIMBINARIES/$DIR_NAME/scripts does not exist. Creating...";
			mkdir "$MIMBINARIES/$DIR_NAME/scripts";
		if [ -e "$MIMBINARIES/$DIR_NAME/bin/mysql_install_db" ]; then
			echo "Creating a symbolic link to $MIMBINARIES/$DIR_NAME/bin/mysql_install_db";
			ln -s "$MIMBINARIES/$DIR_NAME/bin/mysql_install_db" "$MIMBINARIES/$DIR_NAME/scripts/mysql_install_db";
		else
			echo "No mysql_install_db to link to. Nothing done.";
		fi
	fi

	
}

function myc_download_release
{
	if [ ! -f "$MIMBINARIES/$(basename $SELECTED_RELEASE)" ]; then
		wget --directory-prefix="$MIMBINARIES" "$SELECTED_RELEASE";
	else
		echo "$(basename $SELECTED_RELEASE) found locally. Skipping download."
	fi;
	myc_prepare_release "$MIMBINARIES/$SELECTED_RELEASE";
}

function myc_build_server
{
	NAME="$1";
	PORT="$2";
	my build "$NAME" "$PORT";
}

function myc_install_server
{
	NAME="$1";
	my install "$NAME";
}

function myc_start_server
{
	NAME="$1";
	my start "$NAME";
}

function myc_build_cluster_servers
{
	myc_build_server "master1" 30001 && echo "Built server master1";
	myc_build_server "master2" 30002 && echo "Built server master2";
	myc_build_server "slave1" 30003 && echo "Built server slave1";
	myc_build_server "slave2" 30004 && echo "Built server slave2";
	myc_build_server "slave3" 30005 && echo "Built server slave3";
	myc_build_server "slave4" 30006  && echo "Built server slave4";
}

function myc_install_cluster_servers
{
	myc_install_server "master1" && echo "Installed server master1";
	myc_install_server "master2" && echo "Installed server master2";
	myc_install_server "slave1" && echo "Installed server slave1";
	myc_install_server "slave2" && echo "Installed server slave2";
	myc_install_server "slave3" && echo "Installed server slave3";
	myc_install_server "slave4" && echo "Installed server slave4";
}

function myc_start_cluster_servers
{
	myc_start_server "master1" && echo "Started server master1";
	myc_start_server "master2" && echo "Started server master2";
	myc_start_server "slave1" && echo "Started server slave1";
	myc_start_server "slave2" && echo "Started server slave2";
	myc_start_server "slave3" && echo "Started server slave3";
	myc_start_server "slave4" && echo "Started server slave4";
}

function myc_destroy_configs
{
	S=-1;
	if [ -n "$MIMHOME" ]; then
		rm -Rf ${MIMHOME}/configs/*.cnf;
		S=0;
	else
		echo "MIMHOME is not set. Aborting...";
		S=1;
	fi;
	return $S;
}

function myc_destroy_datadirs
{
	S=-1;
	if [ -n "$MIMHOME" ]; then
		rm -Rf ${MIMHOME}/data/*;
		S=0;
	else
		echo "MIMHOME is not set. Aborting...";
		S=1;
	fi;
	return $S;
}

function myc_destroy_cluster
{
	myc_destroy_configs;
	myc_destroy_datadirs;
}

function myc_execute_mysql_query
{
	QUERY="$1";
}

function myc_mysql_secure_installation
{
	if [ ! $(type mysql_secure_installation) ]; then
		echo "mysql_secure_installation not implemented here yet!";
	else
		echo "mysql_secure_installation not available. Be sure to secure your MariaDB/MySQL instances.";
	fi;
}

function myc_write_config
{
	echo "No functionality implemented here yet!";
}

# Main function for setting up the cluster here
function myc_setup_cluster
{
	myc_setup_env;
	myc_download_release;
	myc_build_cluster_servers;
	myc_install_cluster_servers;
	myc_start_cluster_servers;
}









