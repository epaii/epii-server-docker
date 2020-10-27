#! /bin/bash

version=0.0.3

function download() {
    docker pull epii/epii-server:${version}
    #version=latest
    docker save epii/epii-server >$(pwd)/epii-server-docker-${version}.tar
}

function install() {

    if [ $# != 2 ]; then
        echo " it is need 2 args"
        exit
    fi

    if ! [ "$1" -gt 0 ] 2>/dev/null; then
        echo " the first param must be a number"
        exit
    fi
    if [ ! -d $2 ]; then
        mkdir -p $2
        chmod -R 0777 $2
    fi
    a_dir=$(readlink -f $2)
    echo -e "port:"$1"\nroot:"$a_dir >$(pwd)/.info

    file="./epii-server-docker-${version}.tar"
    if [ -f "$file" ]; then
        docker load <$file
    else
        docker pull epii/epii-server:${version}
    fi
    docker tag epii/epii-server:${version} epii-server:${version}
    ln -s $(pwd)/epii-server-docker.sh /usr/local/bin/epii-server-docker
    docker run --restart=always --name esc-${version} -p $1:80 -v $a_dir:/epii -itd epii-server:${version} /bin/bash
    start
}

function uninstall() {
    docker container rm -f esc-$version
    docker image rm epii-server:$version
    docker image rm epii/epii-server:$version
    rm -rf /usr/local/bin/epii-server-docker
}
function start() {

    docker container ls | grep esc-${version} >/dev/null 2>&1 || { docker container start esc-${version}; }

    docker exec esc-${version} bash -c "cd /epii-server ; sh ./start.sh"
}
function stop() {
    docker exec esc-${version} bash -c "cd /epii-server ; sh ./stop.sh"
}
function restart() {
    stop
    start
}
function info() {
    curPath=$(dirname $(readlink -f "$0"))
    cat $curPath/.info
}

function gitinit() {
    docker exec esc-${version} bash -c "sh /scripts/initgit.sh"
}

function newsite() {
    if [ $# != 1 ]; then
        echo " it is need 2 args"
        exit
    fi
    docker exec esc-${version} bash -c " php /webs/git-auto-website/bind.php /epii/repos/$1.git /epii/webs/$1"

}

function mysql() {
 
    if [ "$(type -t mysql_$1)" == function ]; then
        mysql_$1 ${@:2}
    fi

   
}
function mysql_install(){
    if [ $# != 3 ]; then
        echo " it is need 3 args"
        exit
    fi

    if ! [ "$1" -gt 0 ] 2>/dev/null; then
        echo " the first param must be a number"
        exit
    fi
    if [ ! -d $3 ]; then
        mkdir -p $3
        chmod -R 0777 $3
    fi
    docker pull mysql
    docker run -p $1:3306 --name esc-mysql -e MYSQL_ROOT_PASSWORD=$2 -v $3:/var/lib/mysql -d mysql
}
function mysql_uninstall(){
    docker stop esc-mysql
    docker rm -f esc-mysql
    docker image rm -f mysql
}
function mysql_stop(){
     
    docker stop esc-mysql
}
function mysql_restart(){
     
    docker restart esc-mysql
}
function mysql_tart(){
     
    docker start esc-mysql
}
 

function help() {
    echo "sudo ./epii-server-docker install 80 /path/to/epii"
    echo "sudo  epii-server-docker stop"
    echo "sudo  epii-server-docker start"
    echo "sudo  epii-server-docker restart"
    echo "sudo  epii-server-docker uninstall"
    echo "sudo  epii-server-docker info"
    echo "sudo  epii-server-docker download"
    echo "sudo  epii-server-docker gitinit"
    echo "sudo  epii-server-docker newsite {sitename}"
    echo "sudo  epii-server-docker mysql install 3306 rootpassword /path/to/data"
    echo "sudo  epii-server-docker mysql uninstall"
    echo "sudo  epii-server-docker mysql start"
    echo "sudo  epii-server-docker mysql stop"
    echo "sudo  epii-server-docker mysql restart"
}

if [ $(id -u) != "0" ]; then
    echo "It is need use sudo."
    exit 1

fi

command -v docker >/dev/null 2>&1 || {
    echo "docker is not installed.  Aborting."
    echo "you can install docker follow this:"
    echo "curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "sudo sh get-docker.sh"
    exit 1
}

if [ "$(type -t $1)" == function ]; then
    $*
else
    help
fi
