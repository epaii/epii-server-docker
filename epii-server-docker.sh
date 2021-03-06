#! /bin/bash

version=latest

function check_port() {
    echo "正在检测端口......"
    pIDa=$(lsof -i :$1 | grep -v "PID" | awk '{print $2}')

    if [ "$pIDa" != "" ]; then
        return 0
    else
        return 1
    fi
}

function download() {
    docker pull epii/epii-server:${version}
    #version=latest
    docker save epii/epii-server >$(pwd)/epii-server-docker-${version}.tar
}

function install() {

    if [ $# != 3 ]; then
        echo " it is need 3 args"
        exit
    fi

    if ! [ "$1" -gt 0 ] 2>/dev/null; then
        echo " the first param must be a number"
        exit
    fi
    if check_port $1; then
        echo "port $1 is be used"
        exit
    fi
    if ! [ "$2" -gt 0 ] 2>/dev/null; then
        echo " the second param must be a number"
        exit
    fi
    if check_port $2; then
        echo "port $2 is be used"
        exit
    fi
    
    if [ ! -d $3 ]; then
        mkdir -p $3
        chmod -R 0777 $3
    fi
    if [ ! -d $3/logs ]; then
        mkdir -p $3/logs
        chmod -R 0777 $3/logs
    fi
    docker network create --driver bridge --subnet=172.18.12.0/16 --gateway=172.18.1.1 epii-net
    a_dir=$(cd $3;pwd)
     
    echo -e "port:"$1","$2"\nroot:"$a_dir >$(pwd)/.info

    file="./epii-server-docker-${version}.tar"
    if [ -f "$file" ]; then
        docker load <$file
    else
        docker pull epii/epii-server:${version}
    fi
    docker tag epii/epii-server:${version} epii-server:${version}
    ln -s $(pwd)/epii-server-docker.sh /usr/local/bin/epii-server-docker
    ln -s $(pwd)/epii-server-docker.sh /usr/local/bin/esd
    docker run --restart=always --network=epii-net --ip 172.18.12.99 --name esc-${version} -p $1:80 -p $2:443 -v $a_dir:/epii -itd epii-server:${version} /bin/bash -c "cd /epii-server ; sh ./start.sh;/bin/bash"
    #start
    #docker exec esc-${version} bash -c "mkdir /epii/logs"
}

function uninstall() {
    docker container rm -f esc-$version
    docker image rm -f epii-server:$version
    docker image rm -f epii/epii-server:$version
    docker network rm epii-net
    rm -rf /usr/local/bin/epii-server-docker
    rm -rf /usr/local/bin/esd
}
function start() {
    docker container ls | grep esc-${version} >/dev/null 2>&1 || { docker container start esc-${version}; }
    docker exec esc-${version} bash -c "cd /epii-server ; sh ./start.sh"
}
function stop() {
    docker exec esc-${version} bash -c "cd /epii-server ; sh ./stop.sh"
}
function bash() {
    docker exec -it esc-${version} /bin/bash
}
function restart() {
    stop
    start
}
function info() {
    curPath=$(dirname $(readlink -f "$0"))
    cat $curPath/.info
}

function git_init() {
    docker exec esc-${version} bash -c "sh /scripts/initgit.sh"
}

function git_add() {
    if [ $# != 1 ]; then
        echo " it is need 2 args"
        exit
    fi
    docker exec esc-${version} bash -c " php /webs/git-auto-website/bind.php /epii/repos/$1.git /epii/webs/$1"

}

function git() {

    if [ "$(type -t git_$1)" == function ]; then
        git_$1 ${@:2}
    fi

}
function mysql() {

    if [ "$(type -t mysql_$1)" == function ]; then
        mysql_$1 ${@:2}
    else
        mysql_info
    fi

}

function mysql_install() {
    if [ $# != 3 ]; then
        echo " it is need 3 args"
        exit
    fi

    if ! [ "$1" -gt 0 ] 2>/dev/null; then
        echo " the first param must be a number"
        exit
    fi
    if check_port $1; then
        echo "port $1 is be used"
        exit
    fi
    data_dir=$(cd $3;pwd)
 
    if [ ! -d $data_dir ]; then
        mkdir -p $data_dir
        chmod -R 0777 $data_dir
    fi
    file="./mysql.tar"
    if [ -f "$file" ]; then
        docker load <$file
    else
         docker pull mysql
    fi
    docker run --restart=always -p $1:3306 --name esc-mysql -e MYSQL_ROOT_PASSWORD=$2  --network=epii-net --ip 172.18.12.100  -v $data_dir:/var/lib/mysql -d mysql --default-authentication-plugin=mysql_native_password
    sleep 10
    docker exec -it esc-mysql  mysql -e"USE mysql -uroot -p$2;alter user 'root'@'localhost'IDENTIFIED BY '$2';CREATE USER 'root'@'172.18.%' IDENTIFIED BY '$2';GRANT all ON *.* TO 'root'@'172.18.%';FLUSH PRIVILEGES;"
    docker restart esc-mysql

}
function mysql_uninstall() {
    docker stop esc-mysql
    docker rm -f esc-mysql
    #docker image rm -f mysql
}
function mysql_stop() {

    docker stop esc-mysql
}
function mysql_restart() {

    docker restart esc-mysql
}
function mysql_start() {

    docker start esc-mysql
}

function mysql_info() {
    docker inspect esc-mysql | grep IPAddress
}

function mysql_bash() {
    docker exec -it esc-mysql /bin/bash
}
function mysql_manager() {
     docker exec -it esc-mysql mysql -uroot -p
}
function mysql_download() {
    docker pull mysql
    docker save mysql >$(pwd)/mysql.tar
}
function help() {
    echo "sudo ./epii-server-docker install 80 443 /path/to/epii"
    echo "sudo  epii-server-docker stop"
    echo "sudo  epii-server-docker start"
    echo "sudo  epii-server-docker restart"
    echo "sudo  epii-server-docker uninstall"
    echo "sudo  epii-server-docker info"
    echo "sudo  epii-server-docker download"
    echo "sudo  epii-server-docker bash"
    echo "sudo  epii-server-docker git init"
    echo "sudo  epii-server-docker git add  {sitename}"
    echo "sudo  epii-server-docker mysql install 3306 rootpassword /path/to/data"
    echo "sudo  epii-server-docker mysql uninstall"
    echo "sudo  epii-server-docker mysql start"
    echo "sudo  epii-server-docker mysql stop"
    echo "sudo  epii-server-docker mysql restart"
    echo "sudo  epii-server-docker mysql info"
    echo "sudo  epii-server-docker mysql bash"
    echo "sudo  epii-server-docker mysql manager"
    echo "sudo  epii-server-docker mysql download"
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
