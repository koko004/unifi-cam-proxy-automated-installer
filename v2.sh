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
    printf "\n${menu}******** System IP $(hostname -I | cut -d' ' -f1) ********${normal}\n"
    printf "${menu}**${number} 1)${menu} INSTALL UNIFI-PROTECT ${normal}\n"
    printf "${menu}**${number} 2)${menu} INSTALL PROXIED CAMERAS ${normal}\n"
    printf "${menu}**${number} 3)${menu} REMOVE UNIFI-PROTECT OR PROXIED CAMERAS ${normal}\n"
    printf "${menu}**${number} 4)${menu} EXECUTE LAZYDOCKER OR INSTALL ${normal}\n"
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
            option_picked "1 - INSTALL UNIFI-PROTECT";
            cd /root
            echo 'REMOVE OLD INSTANCE IF EXIST'
            docker container stop unifi-protect-x86
            docker container rm unifi-protect-x86
            docker volume rm unifi-protect_unifi-protect && docker volume rm unifi-protect_unifi-protect-db
            docker image rm markdegroot/unifi-protect-x86
            rm -rf unifi-protect
            echo 'OLD INSTANCE IF EXIST WAS REMOVED'
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
docker-compose up -d
echo 'UNIFI-PROTECT UP'
echo "You can login in now in https://$(hostname -I | cut -d' ' -f1):7443"
echo 'INSTALLED';
            show_menu;
        ;;
        2) clear;
            option_picked "INSTALL PROXY CAMERAS";
echo "How many cams do you want install (1-3)?"
read "caminstall"
case $caminstall in
    1)
        echo "Install 1 camera"
        #CAM1
rm -rf /root/unifi-cam-proxy1/
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
echo 'DOCKER-COMPOSE CREATED'
#ENTRYPOINT CREATION
mkdir /root/unifi-cam-proxy1/docker
cd /root/unifi-cam-proxy1/docker
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:20:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
echo 'ENTRYPOINT CREATED'

#CERT RECREATION
cd /root/unifi-cam-proxy1
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
echo 'CERTS CREATED'

#UP
docker-compose up -d
echo 'UP CAM1'
        ;;
    2)
        echo "Install 2 cameras"
#CAM1
rm -rf /root/unifi-cam-proxy1/
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
echo 'DOCKER-COMPOSE CREATED'
#ENTRYPOINT CREATION
mkdir /root/unifi-cam-proxy1/docker
cd /root/unifi-cam-proxy1/docker
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:20:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
echo 'ENTRYPOINT CREATED'

#CERT RECREATION
cd /root/unifi-cam-proxy1
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
echo 'CERTS CREATED'

#UP
docker-compose up -d
echo 'UP CAM1'

#CAM2
rm -rf /root/unifi-cam-proxy2/
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
echo 'DOCKER-COMPOSE CREATED'
#ENTRYPOINT CREATION
mkdir /root/unifi-cam-proxy2/docker
cd /root/unifi-cam-proxy2/docker
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:30:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
echo 'ENTRYPOINT CREATED'

#CERT RECREATION
cd /root/unifi-cam-proxy2
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
echo 'CERTS CREATED'

#UP
docker-compose up -d
echo 'UP CAM2'
        ;;
    3)
        echo "Instalacion de 3 camaras"
#CAM1
rm -rf /root/unifi-cam-proxy1/
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
echo 'DOCKER-COMPOSE CREATED'
#ENTRYPOINT CREATION
mkdir /root/unifi-cam-proxy1/docker
cd /root/unifi-cam-proxy1/docker
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:20:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
echo 'ENTRYPOINT CREATED'

#CERT RECREATION
cd /root/unifi-cam-proxy1
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
echo 'CERTS CREATED'

#UP
docker-compose up -d
echo 'UP CAM1'

#CAM2
rm -rf /root/unifi-cam-proxy2/
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
echo 'DOCKER-COMPOSE CREATED'
#ENTRYPOINT CREATION
mkdir /root/unifi-cam-proxy2/docker
cd /root/unifi-cam-proxy2/docker
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:30:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
echo 'ENTRYPOINT CREATED'

#CERT RECREATION
cd /root/unifi-cam-proxy2
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
echo 'CERTS CREATED'

#UP
docker-compose up -d
echo 'UP CAM2'

#CAM3
rm -rf /root/unifi-cam-proxy3/
git clone https://github.com/koko004/unifi-cam-proxy-automated-installer /root/unifi-cam-proxy3
cd /root/unifi-cam-proxy3
            echo 'Set IP for NVR 3'
            read NVRIP3
            echo 'Set TOKEN for camera 3'
            read TOKENCAM3
            echo 'Set RTSP URL for camera 3'
            read RTSPURLCAM2
echo "version: '3.2'
services:
  unifi-cam-proxy3:
    build: .
    container_name: unifi-cam-proxy3
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=$NVRIP3"
      - "TOKEN=$TOKENCAM3"
      - "RTSP_URL=$RTSPURLCAM3"
    restart: always" >> docker-compose.yml
echo 'DOCKER-COMPOSE CREATED'
#ENTRYPOINT CREATION
mkdir /root/unifi-cam-proxy3/docker
cd /root/unifi-cam-proxy3/docker
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:40:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi
exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
echo 'ENTRYPOINT CREATED'

#CERT RECREATION
cd /root/unifi-cam-proxy3
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
echo 'CERTS CREATED'

#UP
docker-compose up -d
echo 'UP CAM3'
        ;;
    *)
        echo "Sorry only 3 cameras for now..."
        ;;
esac;
            show_menu;
        ;;
        3) clear;
            option_picked "REMOVE UNIFI-PROTECT OR PROXIED CAMERAS";
echo "What do you want remove?"
echo '1 for UNIFI PROTECT'
echo '2 for PROXIED CAMERAS'
read "camremove"
case $camremove in
    1)
        echo "REMOVE UNIFI-PROTECT"
#CLEAN FOLDER
rm -rf unifi-protect
#CLEAN CONTAINER
docker container stop unifi-protect-x86
docker container rm unifi-protect-x86
#CLEAN IMAGE
docker image rm markdegroot/unifi-protect-x86:latest
#CLEAN VOLUMES
docker volume rm unifi-protect_unifi-protect unifi-protect_unifi-protect-db
echo 'CLEANED'
        ;;
    2)
        echo "REMOVE CAMERAS"
#CLEAN FOLDERS
rm -rf /root/unifi-cam-proxy1 /root/unifi-cam-proxy2 /root/unifi-cam-proxy3
#CLEAN CONTAINERS
docker container stop unifi-cam-proxy1 unifi-cam-proxy2 unifi-cam-proxy3
docker container rm unifi-cam-proxy1 unifi-cam-proxy2 unifi-cam-proxy3
#CLEAN IMAGES
docker image rm python:3.8-alpine3.10 unifi-cam-proxy1_unifi-cam-proxy1:latest unifi-cam-proxy2_unifi-cam-proxy2:latest unifi-cam-proxy3_unifi-cam-proxy3:latest
#CLEAN NETWORKS
docker network rm unifi-cam-proxy1_default unifi-cam-proxy2_default unifi-cam-proxy3_default
echo 'CLEANED'
        ;;
    *)
        echo "Sorry only 2 options"
        ;;
esac
            show_menu;
        ;;
        4) clear;
            option_picked "INSTALL OR EXECUTE LAZYDOCKER";

echo "What do you want, install or execute LAZYDOCKER?"
echo '1 for EXECUTE'
echo '2 for INSTALL'
read "lazydocker"
case $lazydocker in
    1)
        echo "EXECUTE"
cd /root && lazydocker
        ;;
    2)
        echo "INSTALL LAZYDOCKER"
            LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

            curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"

            mkdir lazydocker-temp
            tar xf lazydocker.tar.gz -C lazydocker-temp
            mv lazydocker-temp/lazydocker /usr/local/bin
            lazydocker --version
            rm -rf lazydocker.tar.gz
            rm -rf lazydocker-temp;
        ;;
    *)
        echo "Sorry only 2 options"
        ;;
esac
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
