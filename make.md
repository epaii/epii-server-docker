epii-server-7-8-dev 的端口为 8180 8181  //http://127.0.0.1:8180/app/test/a.php


# 进入bash
docker exec -it epii-server-7-8-dev /bin/bash

# 导出为镜像
docker commit epii-server-7-8-dev epii/epii-server:8.3_8.0_7.2

# 保存为tar离线版本
docker save epii/epii-server:8.3_8.0_7.2 -o  epii-server-docker-8.3_8.0_7.2.tar

