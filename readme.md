### install
```
mkdir epii-server-docker
cd epii-server-docker
curl -fsSL https://gitee.com/epii/epii-server-docker/raw/master/epii-server-docker.sh -o epii-server-docker.sh
chmod +x  ./epii-server-docker.sh

sudo apt install docker.io

sudo ./epii-server-docker.sh install 80 443 /path/to/epii

如果失败：通过 tar 文件

```


```
    sudo ./epii-server-docker.sh install 80 443 /path/to/epii
    sudo  epii-server-docker stop
    sudo  epii-server-docker start
    sudo  epii-server-docker restart
    sudo  epii-server-docker app list
    sudo  epii-server-docker uninstall
    sudo  epii-server-docker info
    sudo  epii-server-docker download
    sudo  epii-server-docker bash
    sudo  epii-server-docker git init
    sudo  epii-server-docker git add  {sitename}
    sudo  epii-server-docker mysql install 3306 rootpassword /path/to/data
    sudo  epii-server-docker mysql uninstall
    sudo  epii-server-docker mysql start
    sudo  epii-server-docker mysql stop
    sudo  epii-server-docker mysql restart
    sudo  epii-server-docker mysql info
    sudo  epii-server-docker mysql bash
    sudo  epii-server-docker mysql manager
    sudo  epii-server-docker mysql download

```


usage:
  
before this you can use
```
sudo  epii-server-docker download
```



