#! /bin/bash

version=0.0.2

function download(){
   docker pull epii/epii-server:${version}
   #version=latest
   docker save epii/epii-server >`pwd`/epii-server-docker-${version}.tar
}

function install () {
    
    if [ $# != 2 ];then
        echo " it is need 2 args";
        exit
    fi
    
    if !  [ "$1" -gt 0 ] 2>/dev/null  ;then
        echo " the first param must be a number";
        exit
    fi
    if [ ! -d $2 ]; then
        mkdir -p $2
    fi
    a_dir=`readlink -f $2`
    echo -e "port:"$1"\nroot:"$a_dir >`pwd`/.info
    
    file="./epii-server-docker-${version}.tar"
    if [ -f "$file" ]
    then
     docker load < $file
    else
     docker pull  epii/epii-server:${version}
    fi
    docker tag epii/epii-server:${version} epii-server:${version}
    ln -s `pwd`/epii-server-docker.sh /usr/local/bin/epii-server-docker
    docker run --restart=always --name esc-${version} -p $1:80 -v $a_dir:/epii -itd  epii-server:${version} /bin/bash
    start
}

function uninstall () {
    docker container rm -f esc-$version
    docker image rm epii-server:$version
    docker image rm epii/epii-server:$version
    rm -rf /usr/local/bin/epii-server-docker
}
function start() {
    
    docker container ls |grep esc-${version} > /dev/null 2>&1  || { docker container start esc-${version}; }
    
    docker exec esc-${version} bash -c "cd /epii-server ; sh ./start.sh"
}
function stop() {
    docker exec esc-${version} bash -c "cd /epii-server ; sh ./stop.sh"
}
function  restart() {
    stop
    start
}
function info(){
    curPath=$(dirname $(readlink -f "$0"))
    cat   $curPath/.info
}

function help(){
    echo "sudo ./epii-server-docker install 80 /path/to/epii"
    echo "sudo  epii-server-docker stop"
    echo "sudo  epii-server-docker start"
    echo "sudo  epii-server-docker restart"
    echo "sudo  epii-server-docker uninstall"
    echo "sudo  epii-server-docker info"
    echo "sudo  epii-server-docker download"

    
}

if [ `id -u` != "0" ] ; then
    echo  "It is need use sudo."
    exit 1
    
fi

command -v docker >/dev/null 2>&1 || { echo  "docker is not installed.  Aborting."; exit 1; }

if [ "$(type -t $1)" == function ]; then
    $*
else
    help
fi
