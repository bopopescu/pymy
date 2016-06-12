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
set -u;

MYSQL_RELEASE="http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.13-linux-glibc2.5-x86_64.tar"
MARIADB_RELEASE="https://downloads.mariadb.org/interstitial/mariadb-10.1.14/bintar-linux-x86_64/mariadb-10.1.14-linux-x86_64.tar.gz"

function myc_setup_env
{
	export MIMBINARIES=~/tmp_mycuster/mim-binaries;
	export MIMHOME=~/tmp_mycluster/mim-databases;
	mkdir -p ~/tmp_mycuster/mim-binaries;
	mkdir -p ~/tmp_mycluster/mim-databases;
}
