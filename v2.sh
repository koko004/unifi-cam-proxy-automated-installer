#!/bin/sh
# Decode QR page https://zxing.org/w/decode.jspx
# Original project https://github.com/keshavdv/unifi-cam-proxy

show_menu(){
    normal=`echo "\033[m"`
    menu=`echo "\033[36m"` #Blue
    number=`echo "\033[33m"` #yellow
    bgred=`echo "\033[41m"`
    fgred=`echo "\033[31m"`
    printf "\n${menu}*********************************************${normal}\n"
    printf "\n${menu}******** U N I F I - CAM - P R O X Y ********${normal}\n"
    printf "\n${menu}******** System IP $(hostname -I | cut -d' ' -f1) ********${normal}\n"
    printf "${menu}**${number} 1)${menu} SET-PARAMETERS${normal}\n"
    printf "${menu}**${number} 2)${menu} REBUILD ${normal}\n"
    printf "${menu}**${number} 3)${menu} INSTALL${normal}\n"
    printf "${menu}**${number} 4)${menu} REMOVE ${normal}\n"
    printf "${menu}**${number} 5)${menu} LAZYDOCKER - INSTALL${normal}\n"
    printf "${menu}**${number} 6)${menu} STATUS - LAZYDOCKER${normal}\n"
    printf "${menu}**${number} 7)${menu} INSTALL UNIFI-PROTECT${normal}\n"

    printf "${menu}*********************************************${normal}\n"
    printf "Please enter a menu option and enter or ${fgred}x to exit. ${normal}"
    read opt
}

option_picked(){
    msgcolor=`echo "\033[01;31m"` # bold red
    normal=`echo "\033[00;00m"` # normal white
    message=${@:-"${normal}Error: No message passed"}
    printf "${msgcolor}${message}${normal}\n"
}

clear
show_menu
while [ $opt != '' ]
    do
    if [ $opt = '' ]; then
      exit;
    else
      case $opt in
        1) clear;
            option_picked "Option 1 SET PARAMETERS";
# ************************************************************************************************* 1
#CAM1
rm /root/unifi-cam-proxy1/docker-compose.yml
mkdir /root/unifi-cam-proxy1
cd /root/unifi-cam-proxy1
            echo 'Set IP for NVR 1'
            read NVRIP1
            echo 'Set TOKEN for camera 1'
            read TOKENCAM1
            echo 'Set RTSP URL for camera 1'
            read RTSPURLCAM1
echo "version: '3.2'
services:
  unifi-cam-proxy1:
    build: .
    container_name: unifi-cam-proxy1
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=$NVRIP1"
      - "TOKEN=$TOKENCAM1"
      - "RTSP_URL=$RTSPURLCAM1"
    restart: always" >> docker-compose.yml

#CAM2
rm /root/unifi-cam-proxy2/docker-compose.yml
mkdir /root/unifi-cam-proxy2
cd /root/unifi-cam-proxy2
            echo 'Set IP for NVR 2'
            read NVRIP2
            echo 'Set TOKEN for camera 2'
            read TOKENCAM2
            echo 'Set RTSP URL for camera 2'
            read RTSPURLCAM2
echo "version: '3.2'
services:
  unifi-cam-proxy2:
    build: .
    container_name: unifi-cam-proxy2
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=$NVRIP2"
      - "TOKEN=$TOKENCAM2"
      - "RTSP_URL=$RTSPURLCAM2"
    restart: always" >> docker-compose.yml
echo 'DONE'    
cd /root; #SET-PARAMETERS;
            show_menu;
        ;;
        2) clear;
            option_picked "Option 2 REBUILD";
# ************************************************************************************************* 2 
#STOP AND REMOVE INSTALLED
            echo 'REMOVE DIRECTORIES' && ls
            docker container stop unifi-cam-proxy1 unifi-cam-proxy2
            echo 'STOP CONTAINERS'
            docker container rm unifi-cam-proxy1 unifi-cam-proxy2
            echo 'REMOVE CONTAINERS' && docker container ls
            docker network rm unifi-cam-proxy1_default && docker network rm unifi-cam-proxy2_default
            echo 'REMOVE NETWORKS' && docker network ls
            docker image rm unifi-cam-proxy1_unifi-cam-proxy1 unifi-cam-proxy2_unifi-cam-proxy2 python:3.8-alpine3.10
            echo 'REMOVE IMAGES' && docker image ls
            echo '************************************************************************************************* ALL ERASED'
#ENTREYPOINTS RECREATION
cd /root/unifi-cam-proxy1/docker
rm /root/unifi-cam-proxy1/docker/entrypoint.sh
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:20:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
cd /root/unifi-cam-proxy2/docker
rm /root/unifi-cam-proxy2/docker/entrypoint.sh
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:30:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
echo 'ENTRY POINTS CREATED'

#CERT RECREATION
cd /root/unifi-cam-proxy1
rm /root/unifi-cam-proxy1/client.pem
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
cd /root/unifi-cam-proxy2
rm /root/unifi-cam-proxy2/client.pem
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
cd /root
echo 'CERTS RECREATED'
cd /root/unifi-cam-proxy1
docker-compose up -d
cd /root/unifi-cam-proxy2
docker-compose up -d
echo 'FINISH REBUILD'; #REBUILD;
            show_menu;
        ;;
        3) clear;
            option_picked "Option 4 COMPLETE INSTALL";
# ************************************************************************************************* 3


#CAM1
rm -rf /root/unifi-cam-proxy1
git clone https://github.com/koko004/unifi-cam-proxy-automated-installer /root/unifi-cam-proxy1
cd /root/unifi-cam-proxy1
            echo 'Set IP for NVR 1'
            read NVRIP1
            echo 'Set TOKEN for camera 1'
            read TOKENCAM1
            echo 'Set RTSP URL for camera 1'
            read RTSPURLCAM1
echo "version: '3.2'
services:
  unifi-cam-proxy1:
    build: .
    container_name: unifi-cam-proxy1
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=$NVRIP1"
      - "TOKEN=$TOKENCAM1"
      - "RTSP_URL=$RTSPURLCAM1"
    restart: always" >> docker-compose.yml
cd /root

#CAM2
rm -rf /root/unifi-cam-proxy2
git clone https://github.com/koko004/unifi-cam-proxy-automated-installer /root/unifi-cam-proxy2
cd /root/unifi-cam-proxy2
            echo 'Set IP for NVR 2'
            read NVRIP2
            echo 'Set TOKEN for camera 2'
            read TOKENCAM2
            echo 'Set RTSP URL for camera 2'
            read RTSPURLCAM2
echo "version: '3.2'
services:
  unifi-cam-proxy2:
    build: .
    container_name: unifi-cam-proxy2
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=$NVRIP2"
      - "TOKEN=$TOKENCAM2"
      - "RTSP_URL=$RTSPURLCAM2"
    restart: always" >> docker-compose.yml
echo 'DONE'


#ENTREYPOINTS CREATION
cd /root/unifi-cam-proxy1/docker
rm entrypoint.sh
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:20:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
cd /root/unifi-cam-proxy2/docker
rm entrypoint.sh
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:30:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
#CERT CREATION
cd /root/unifi-cam-proxy1
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
cd /root/unifi-cam-proxy2
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
cd /root
echo 'CERTS CREATED'

echo ' ************************************************************************************************* ALL RECREATED'
cd /root/unifi-cam-proxy1 && docker-compose up -d
echo ' ************************************************************************************************* CAM1 RECREATED'
cd ..
cd /root/unifi-cam-proxy2 && docker-compose up -d
cd ..
echo ' ************************************************************************************************* CAM2 RECREATED'; #INSTALL;
            show_menu;
        ;;
        4) clear;
            option_picked "Option 4 COMPLETE REMOVE";
# ************************************************************************************************* 4
            cd /root
            rm -rf unifi-cam-proxy1 unifi-cam-proxy2
            echo 'REMOVE DIRECTORIES' && ls
            docker container stop unifi-cam-proxy1 unifi-cam-proxy2
            echo 'STOP CONTAINERS'
            docker container rm unifi-cam-proxy1 unifi-cam-proxy2
            echo 'REMOVE CONTAINERS' && docker container ls
            docker network rm unifi-cam-proxy1_default && docker network rm unifi-cam-proxy2_default
            echo 'REMOVE NETWORKS' && docker network ls
            docker image remove unifi-cam-proxy1-unifi-cam-proxy1 unifi-cam-proxy2-unifi-cam-proxy2 python:3.8-alpine3.10
            echo 'REMOVE IMAGES' && docker image ls
            echo '************************************************************************************************* ALL ERASED'; #REMOVED;
            show_menu;
        ;;
        5) clear;
            option_picked "Option 5 LAZYDOCKER";
# ************************************************************************************************* 5
            LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

            curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"

            mkdir lazydocker-temp
            tar xf lazydocker.tar.gz -C lazydocker-temp
            mv lazydocker-temp/lazydocker /usr/local/bin
            lazydocker --version
            rm -rf lazydocker.tar.gz
            rm -rf lazydocker-temp;
            show_menu;
        ;;
        6) clear;
            option_picked "Option 6 STATUS";
# ************************************************************************************************* 6
            lazydocker; #STATUS;
            show_menu;
        ;;
         7) clear;
            option_picked "Option 7 UNIFI-PROTECT";
# ************************************************************************************************* 7
            cd /root
            echo 'REMOVE OLD INSTANCE IF EXIST'
            docker container stop unifi-protect-x86
            docker container rm unifi-protect-x86
            docker volume rm unifi-protect_unifi-protect && docker volume rm unifi-protect_unifi-protect-db
            docker image rm markdegroot/unifi-protect-x86
            rm -rf unifi-protect
            echo 'OLD INSTANCE REMOVED'
            echo 'INSTALL UNIFI-PROTECT'
            mkdir unifi-protect && cd unifi-protect
            echo "version: '3'
services:
  unifi-protect:
    container_name: unifi-protect-x86
    ports:
        - '7080:7080'
        - '7442:7442'
        - '7443:7443'
        - '7444:7444'
        - '7447:7447'
        - '7550:7550'
    volumes:
        - 'unifi-protect:/srv/unifi-protect'
        - 'unifi-protect-db:/var/lib/postgresql/10/main'
    environment:
        - TZ=Europe/Madrid
        - PUID=999
        - PGID=999
        - PUID_POSTGRES=102
        - PGID_POSTGRES=104
    deploy:
      resources:
        limits:
          memory: 1024M
    network_mode: host
    restart: always
    tmpfs:
      - /srv/unifi-protect/temp
    image: markdegroot/unifi-protect-x86:latest
volumes:
   unifi-protect:
   unifi-protect-db:" >> docker-compose.yml
echo 'COMPOSE CREATED'
echo 'UNIFI-PROTECT UP'
docker-compose up -d
echo 'You can login in your https ip port 7443'
echo 'INSTALLED'; #UNIFI-PROTECT;
            show_menu;
        ;;
        x)exit;
        ;;
        \n)exit;
        ;;
        *)clear;
            option_picked "Pick an option from the menu";
            show_menu;
        ;;
      esac
    fi
done
