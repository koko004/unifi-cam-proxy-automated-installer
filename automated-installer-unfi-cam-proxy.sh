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
    printf "${menu}**${number} 1)${menu} CHANGED PARAMETERS - RECONTRUCT${normal}\n"
    printf "${menu}**${number} 2)${menu} REMOVE ALL ${normal}\n"
    printf "${menu}**${number} 3)${menu} INSTALL ${normal}\n"
    printf "${menu}**${number} 4)${menu} LAZYDOCKER ${normal}\n"
    printf "${menu}**${number} 5)${menu} STATUS${normal}\n"
    printf "${menu}**${number} 6)${menu} INSTALL UNIFI-PROTECT${normal}\n"
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
            option_picked "Option 1 CHANGED PARAMETERS";
# ************************************************************************************************* 1 
            docker container stop unifi-cam-proxy1 unifi-cam-proxy2
            echo 'STOP CONTAINERS'
            docker container rm unifi-cam-proxy1 unifi-cam-proxy2
            echo 'REMOVE CONTAINERS' && docker container ls
            docker network rm unifi-cam-proxy1_default && docker network rm unifi-cam-proxy2_default
            echo 'REMOVE NETWORKS' && docker network ls
            docker image rm unifi-cam-proxy1_unifi-cam-proxy1 unifi-cam-proxy2_unifi-cam-proxy2 python:3.8-alpine3.10
            echo 'REMOVE IMAGES' && docker image ls
            cd /root
            cd unifi-cam-proxy1
            rm -rf unifi-cam-proxy1/docker-compose.yml
            rm -rf unifi-cam-proxy1/docker/entrypoint.sh
            cd /root
            cd unifi-cam-proxy2
            rm -rf unifi-cam-proxy2/docker-compose.yml
            rm -rf unifi-cam-proxy2/docker/entrypoint.sh
            cd /root
            cd unifi-cam-proxy1            
echo "version: '3.2'
services:
  unifi-cam-proxy1:
    build: .
    container_name: unifi-cam-proxy1
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=192.168.1.228"
      - "TOKEN=B7CanJmwUbGbCiW1UfLMZHj0LSyVFka8"
      - "RTSP_URL=rtsp://hassio:adolfin21@192.168.1.75:554/stream1"
    restart: always" >> docker-compose.yml
cd /root
cd unifi-cam-proxy2
echo "version: '3.2'
services:   
  unifi-cam-proxy2:
    build: .
    container_name: unifi-cam-proxy2
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=192.168.1.228"
      - "TOKEN=B7CanJmwUbGbCiW1UfLMZHj0LSyVFka8"
      - "RTSP_URL=rtsp://admin:@192.168.1.77:554"
    restart: always" >> docker-compose.yml
cd /root
cd unifi-cam-proxy1
echo '#!/bin/sh

if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:20:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi

exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
cd /root
cd unifi-cam-proxy2
echo '#!/bin/sh

if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:30:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi

exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
cd /root
cd unifi-cam-proxy1
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
cd /root
cd unifi-cam-proxy2
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr
cd /root
#IF FAILS REMOVE CREATED FILES
rm -rf client.pem docker-compose.yml entrypoint.sh
echo ' ************************************************************************************************* ALL RECREATED'
cd unifi-cam-proxy1 && docker-compose up -d
echo ' ************************************************************************************************* CAM1 RECREATED'
cd ..
cd unifi-cam-proxy2 && docker-compose up -d
cd ..
echo ' ************************************************************************************************* CAM2 RECREATED';
            show_menu;
        ;;
        2) clear;
            option_picked "Option 2 COMPLETE REMOVE";
# ************************************************************************************************* 2
            rm -rf unifi-cam-proxy1 unifi-cam-proxy2
            echo 'REMOVE DIRECTORIES' && ls
            docker container stop unifi-cam-proxy1 unifi-cam-proxy2
            echo 'STOP CONTAINERS'
            docker container rm unifi-cam-proxy1 unifi-cam-proxy2
            echo 'REMOVE CONTAINERS' && docker container ls
            docker network rm unifi-cam-proxy1_default && docker network rm unifi-cam-proxy2_default
            echo 'REMOVE NETWORKS' && docker network ls
            docker image rm unifi-cam-proxy1_unifi-cam-proxy1 unifi-cam-proxy2_unifi-cam-proxy2 python:3.8-alpine3.10
            echo 'REMOVE IMAGES' && docker image ls
            echo '************************************************************************************************* ALL ERASE'; #REINSTALL;
            show_menu;
        ;;
        3) clear;
            option_picked "Option 3 COMPLETE INSTALL";
# ************************************************************************************************* 3
cd ..
#!/bin/sh
#cam1
git clone https://github.com/koko004/unifi-cam-proxy-automated-installer unifi-cam-proxy1
cd unifi-cam-proxy1
rm docker-compose.yml
echo "version: '3.2'
services:
  unifi-cam-proxy1:
    build: .
    container_name: unifi-cam-proxy1
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=192.168.1.228"
      - "TOKEN=jL9VjlrYedc2tu0tKDH1nKIdMNF7gMnV"
      - "RTSP_URL=rtsp://hassio:adolfin21@192.168.1.75:554/stream1"
    restart: always" >> docker-compose.yml

echo '***** COMPOSED CREATED *****'

#certificate
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr

echo '***** CERT CREATED *****'

#entrypoing

cd docker
rm entrypoint.sh
echo '#!/bin/sh

if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:01:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi

exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
cd ..
echo '***** ENTRYPOINT CREATED *****'

#up
docker-compose up -d
cd ..
echo '****************************************************************** CAM 1 UP *****'

#cam2
git clone https://github.com/koko004/unifi-cam-proxy-automated-installer unifi-cam-proxy2
mv unifi-cam-proxy-automated-installer unifi-cam-proxy2
cd unifi-cam-proxy2
rm docker-compose.yml

echo "version: '3.2'
services:   
  unifi-cam-proxy2:
    build: .
    container_name: unifi-cam-proxy2
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=192.168.1.228"
      - "TOKEN=jL9VjlrYedc2tu0tKDH1nKIdMNF7gMnV"
      - "RTSP_URL=rtsp://admin:@192.168.1.77:554"
    restart: always" >> docker-compose.yml

echo '***** COMPOSE CREATED *****'

#certificate
openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr

echo '***** CERT CREATED *****'

#entrypoint
cd docker
rm entrypoint.sh

echo '#!/bin/sh

if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:02:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
fi

exec "$@"' >> entrypoint.sh
chmod +x entrypoint.sh
cd ..
echo '***** ENTRYPOINT CREATED *****'

#up
docker-compose up -d
echo '****************************************************************** CAM 2 UP'
cd ..

echo '******************************************************************  INSTALL COMPLETE ****************************************************************** ';
            show_menu;
        ;;
        4) clear;
            option_picked "Option 4 LAZYDOCKER";
# ************************************************************************************************* 4
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
        5) clear;
            option_picked "Option 5 STATUS";
# ************************************************************************************************* 5
            lazydocker; #STATUS;
            show_menu;
        ;;
         6) clear;
            option_picked "Option 6 UNIFI-PROTECT";
# ************************************************************************************************* 5
            cd /root
            mkdir unifi-protect
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
docker-compose up -d; #UNIFI-PROTECT;
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
