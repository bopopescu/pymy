####################################################
# Author: Rhys Campbell                            #
# Created: 2016-06-10                              #
# Description: For the MariaDB DBA...              #
####################################################
import os
import collections

def cluster_configuration_files(path):
    cluster_files = []
    for file in os.listdir(path):
        if file.endswith('.cfg'):
            cluster_files.append(os.path.abspath(file))
    return sorted(cluster_files)

def cluster_configuration_dictionary(cluster_configuration_files):
    cluster_dictionary = {}
    index = 1
    for file in cluster_configuration_files:
        cluster_dictionary[str(index)]=file
        index = index + 1
    return collections.OrderedDict(sorted(cluster_dictionary.items()))

def print_cluster_menu(cluster_configuration_dictionary):
    format_string = "{:<3} {:<10}"
    for key in cluster_configuration_dictionary:
        cluster_name = os.path.splitext(os.path.basename(cluster_configuration_dictionary[key]))[0]
        print format_string.format(str(key), cluster_name)


if __name__ == "__main__":
    print_cluster_menu(cluster_configuration_dictionary(cluster_configuration_files('./config')))