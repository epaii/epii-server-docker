### install
```
mkdir epii-server-docker
cd epii-server-docker
curl -fsSL https://gitee.com/epii/epii-server-docker/raw/master/epii-server-docker.sh -o epii-server-docker.sh
chmod +x  ./epii-server-docker.sh
sudo ./epii-server-docker.sh install 80 /path/to/epii
```


usage:
 

```
    echo "sudo ./epii-server-docker install 80 /path/to/epii"
    echo "sudo  epii-server-docker stop"
    echo "sudo  epii-server-docker start"
    echo "sudo  epii-server-docker restart"
    echo "sudo  epii-server-docker uninstall"
    echo "sudo  epii-server-docker info"
    echo "sudo  epii-server-docker download"
    echo "sudo  epii-server-docker gitinit"
    echo "sudo  epii-server-docker newsite {sitename}"
    echo "sudo  epii-server-docker mysql install 3306 password /path/to/data"
    echo "sudo  epii-server-docker mysql uninstall"
    echo "sudo  epii-server-docker mysql start"
    echo "sudo  epii-server-docker mysql stop"
    echo "sudo  epii-server-docker mysql restart"
```

before this you can use
```
echo "sudo  epii-server-docker download"
```

