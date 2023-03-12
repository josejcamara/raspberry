# Montar servidor Plex en Raspberry

Basicamente, seguí los pasos de este repo/tutorial:  
- https://github.com/pablokbs/plex-rpi
- https://www.youtube.com/watch?v=7LiHtL-veCc&list=WL&index=13

## Preparación

1. Instalar Raspberry Pi OS Lite 64bits (Raspberry4 - 4Gb)  
    1. Usando Pi-Imager
    1. Utiliza el [Menu Avanzado](https://www.raspberrypi.com/documentation/computers/getting-started.html#advanced-options) para configurar el acceso SSH y el usuario por defecto (Lite no tiene GUI)
1. Conectate a la raspberry por SSH
1. Actualiza el sistema e instala `git` 
1. Monta el disco usb
    1. sudo su
    1. mkdir /mnt/storage
    1. fdisk -l
    1. /dev/sda1 /mnt/storage vfat defaults,uid=1000,gid=1000,umask=022 0 0 | tee -a /etc/fstab
    1. mount -a
1. Clona el repositorio del tutorial
1. Sigue los pasos del tutorial. Algunos pasos detallados a continuación
1. Revisa los valores del fichero `.env` y pon la contrasena de tu raspberry
1. Revisa el password de "transmission" en `docker-compose.yaml`. La utilizaras para acceder a la web UI
1. Ejecuta `docker-compose up -d`
1. Accede a la web usando la IP de la raspberry. `http://192.168.0.40:32400/web/index.html`
1. Configura Plex como se dice en el video
    - Deshabilita transcoding para que la raspberry no colapse.

## Adicionalmente

### Instala VPN
1. Descarga el [fichero ovpn](https://support.surfshark.com/hc/en-us/articles/360013425373-How-to-set-up-Surfshark-VPN-on-Raspberry-Pi-) en `/home/pi/vpn/yourfile.ovpn`

1. Crea un [fichero "pass"](https://www.ivpn.net/setup/linux-terminal/) para tomar las credenciales automaticamente en  `/home/pi/vpn/surfshark.pass`

1. Edita `yourfile.ovpn` como se indica en el link anterior para enlazar el fichero de credentiales.

1. Crea este script en tu carpeta personal `check_vpn.sh` 
    ```
    if [ "0" == `ifconfig | grep tun0 | wc -l` ]; 
    then 
        echo `date` No VPN!! Reconnecting
        sudo -b openvpn /home/pi/vpn/es-mad-surfshark.ovpn
    else
        echo `date` VPN still up 
    fi
    ```
1. Crea un cron que lo ejecute
    > 15 0 * * *  /home/pi/check_vpn.sh >> /home/pi/vpn_cron.log 2>&1



## Pruebas 
(descrito en el video tutorial):

1. Descarga la pelicula gratuita "[Big Buck Bunny](
magnet:?xt=urn:btih:dd8255ecdc7ca55fb0bbf81323d87062db1f6d1c&dn=Big%20Buck%20Bunny%20%282008%29&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Fexplodie.org%3A6969&tr=udp%3A%2F%2Ftracker.empire-js.us%3A1337&ws=https%3A%2F%2Fwebtorrent.io%2Ftorrents%2F)"

1. Ejecuta flexget para mueva el fichero a Plex
> docker-compose exec flexget flexget execute --dump --tasks sort_movies

1. Si necesitas relanzar el comando, primero necesitas que flexget "olvide" que ya lo hizo
> docker-compose exec flexget flexget seen forget file:///downloads/complete/Big%20Buck%20Bunny%20%282008%29/Big%20Buck%20Bunny.mp4 



