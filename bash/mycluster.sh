#!/usr/bin/env bash
#################################################
# Author: Rhys Campbell                         #
# Created: 2016-06-12                           #
# Description: Creates and configures a MariaDB #
# cluster. Uses the my tool from...             #
# https://github.com/mathnode/mim               #
#################################################

set -e;
set -o pipefail;
#set -u;

if [ $(uname) == "Darwin" ]; then
	MYSQL_RELEASE="http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.13-osx10.11-x86_64.tar.gz"
	MARIADB_RELEASE=MYSQL_RELEASE;
	echo "Note: no currently available tar release for MariaDB. Using MySQL."
elif [ $(uname) == "Linux" ]; then
	MYSQL_RELEASE="http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.13-linux-glibc2.5-x86_64.tar"
	MARIADB_RELEASE="https://downloads.mariadb.org/interstitial/mariadb-10.1.14/bintar-linux-x86_64/mariadb-10.1.14-linux-x86_64.tar.gz"
else
	echo "Unsupported Operating System";
	exit 1;
fi;

SELECTED_RELEASE="$MYSQL_RELEASE";

function myc_setup_env
{
	export MIMBINARIES=~/tmp_mycuster/mim-binaries;
	export MIMHOME=~/tmp_mycluster/mim-databases;
	mkdir -p ~/tmp_mycuster/mim-binaries;
	mkdir -p ~/tmp_mycluster/mim-databases;
}

function myc_download_releases
{
	if [ ! -f "$MIMBINARIES/$(basename $SELECTED_RELEASE)" ]; then
		wget --directory-prefix="$MIMBINARIES" "$SELECTED_RELEASE";
	else
		echo "$(basename $SELECTED_RELEASE) found locally. Skipping download."
	fi;
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
	myc_build_server "slave1" 30004 && echo "Built server slave2";
	myc_build_server "slave1" 30005 && echo "Built server slave3";
	myc_build_server "slave1" 30006  && echo "Built server slave4";
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

function myc_execute_mysql_query
{
	
}

function myc_mysql_secure_installation
{
	
}

function myc_write_config
{
	
}











