#!/bin/bash

echo "Cuantas camaras necesitas"
read "caminstall"
case $caminstall in
    1)
        echo "Instalacion de 1 camara"
        #CAM1
rm -rf /root/unifi-cam-proxy3/
mkdir /root/unifi-cam-proxy3
cd /root/unifi-cam-proxy3
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
    container_name: unifi-cam-proxy3
    volumes:
      - './client.pem:/client.pem'
    environment:
      - "HOST=$NVRIP1"
      - "TOKEN=$TOKENCAM1"
      - "RTSP_URL=$RTSPURLCAM1"
    restart: always" >> docker-compose.yml
echo 'DOCKER-COMPOSE CREATED'
#ENTRYPOINT CREATION
mkdir /root/unifi-cam-proxy3/docker
cd /root/unifi-cam-proxy3/docker
echo '#!/bin/sh
if [ ! -z "${RTSP_URL:-}" ] && [ ! -z "${HOST}" ] && [ ! -z "${TOKEN}" ]; then
  echo "Using RTSP stream from $RTSP_URL"
  exec unifi-cam-proxy --host "$HOST" --name "${NAME:-unifi-cam-proxy}" --mac "${MAC:-'AA:BB:CC:00:20:22'}" --cert /client.pem --token "$TOKEN" rtsp -s "$RTSP_URL"
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
echo 'UP CAM1'
        ;;
    2)
        echo "Instalacion de 2 camaras"
        ;;
    3)
        echo "Instalacion de 3 camaras"
        ;;
    4)
        echo "Instalacion de 4 camaras"
        ;;
    *)
        echo "Lo siento, solo hasta 4 camaras"
        ;;
esac 
