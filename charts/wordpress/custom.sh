#!/bin/bash
set -x

CHART_DIRECTORY=$1
[ ! -d "$CHART_DIRECTORY" ] && echo "custom shell: error, miss CHART_DIRECTORY $CHART_DIRECTORY " && exit 1

cd $CHART_DIRECTORY
echo "custom shell: CHART_DIRECTORY $CHART_DIRECTORY"
echo "CHART_DIRECTORY $(ls)"

#========================= add your customize bellow ====================
#===============================

set -o errexit
set -o pipefail
set -o nounset

if ! which yq &>/dev/null ; then
    echo " 'yq' no found"
    if [ "$(uname)" == "Darwin" ];then
      exit 1
    fi
    echo "try to install..."
    YQ_VERSION=v4.30.6
    YQ_BINARY="yq_$(uname | tr 'A-Z' 'a-z')_amd64"
    wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O /tmp/yq.tar.gz &&
     tar -xzf /tmp/yq.tar.gz -C /tmp &&
     mv /tmp/${YQ_BINARY} /usr/bin/yq
fi

if [ "$(uname)" == "Darwin" ];then
   sed  -i  's?docker.io?m.daocloud.io/docker.io?' values.yaml
   sed  -i  's?docker.io?m.daocloud.io/docker.io?' charts/wordpress/charts/memcached/values.yaml
   sed  -i  's?docker.io?m.daocloud.io/docker.io?' charts/wordpress/charts/mariadb/values.yaml
else
   sed  -i  's?docke.io?m.daocloud.io/docker.io?' values.yaml
   sed  -i  's?docker.io?m.daocloud.io/docker.io?' charts/wordpress/charts/memcached/values.yaml
   sed  -i  's?docker.io?m.daocloud.io/docker.io?' charts/wordpress/charts/mariadb/values.yaml
fi

yq -i '
  .wordpress.mariadb.image.registry = "m.daocloud.io/docker.io" |
  .wordpress.mariadb.image.repository = "bitnami/mariadb" |
  .wordpress.mariadb.image.tag = "10.6.12-debian-11-r0" |
  .wordpress.memcached.image.registry = "m.daocloud.io/docker.io" |
  .wordpress.memcached.image.repository = "bitnami/memcached" |
  .wordpress.memcached.image.tag = "1.6.18-debian-11-r0" 
' values.yaml