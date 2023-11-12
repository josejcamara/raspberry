# Montar servidor Plex en Raspberry con Docker

Con este repo puedes crear tu propio server que descarga tus series y peliculas automáticamente, y cuando finaliza, las copia al directorio `media/` donde Plex las encuentra y las agrega a tu biblioteca.

También contiene un pequeño server samba por si quieres compartir los archivos por red.

NOTA: Este repo fue configurado para correr usando flexget y transmission [en este video](https://youtu.be/TqVoHWjz_tI)

Basicamente, seguí los pasos de este tutorial:  
- https://github.com/pablokbs/plex-rpi
- https://www.youtube.com/watch?v=7LiHtL-veCc&list=WL&index=13

## Preparación

1. Instalar Raspberry Pi OS Lite 64bits (Raspberry4 - 4Gb)  
    1. Usando Pi-Imager
    1. Utiliza el [Menu Avanzado](https://www.raspberrypi.com/documentation/computers/getting-started.html#advanced-options) para configurar el acceso SSH y el usuario por defecto (Lite no tiene GUI)
1. Conectate a la raspberry por SSH
1. `sudo apt update` and `sudo apt upgrade`
1. Instala los paquetes basicos
    ```
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common \
        git \
        vim \
        fail2ban \
        ntfs-3g
    ```
1. Instala Docker
    ```
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    [It may fail - restart and try again]
    sudo usermod -aG docker pi
    #(logout and login)
    sudo systemctl enable docker
    ```
1. Instala docker-compose
    ```
    sudo apt-get install libffi-dev libssl-dev
    sudo apt install python3-dev
    sudo apt-get install -y python3 python3-pip
    sudo pip3 install docker-compose
    ```
1. Modificá tu docker config para que guarde los temps en el disco (que montas en el siguiente paso) en vez de en la SD:
    ```
    sudo vim /etc/default/docker
    # Agregar esta linea al final con la ruta de tu disco externo montado
    export DOCKER_TMPDIR="/mnt/storage/docker-tmp"
    ```

1. Monta el disco usb
    1. sudo su
    1. mkdir /mnt/storage
    1. fdisk -l  (supongamos que tienes /dev/sda1 y es tu disco)
    1. echo /dev/sda1 /mnt/storage ntfs-3g defaults,auto 0 0 | tee -a /etc/fstab
    1. mount -a

1. Clona el repositorio de este tutorial (o el original) en tu home.
1. Revisa los valores del fichero `.env` y revisa las contrasenas
    1. Pon un password fuerte para flexget o te dara fallo al iniciar
    1. Transmission está preconfigurado con `admin/123456`. 

1. Ejecuta `docker-compose up -d`

1. Configura Plex como se dice en el video
    - Deshabilita transcoding para que la raspberry no colapse.
    - Habilita la actualizacion automatica cuando haya cambios

## URLs

- **Transmission**: http://<raspberry_ip>:9091/transmission/web/
- **Plex**: http://<raspberry_ip>:32400/web/index.html

## Adicionalmente

### Instala VPN
Nota: El repo ya contiene la configuracion en el directorio vpn, pero estos son los pasos a seguir en caso que se cambie de proveedor.
1. Descarga el [fichero ovpn](https://support.surfshark.com/hc/en-us/articles/360013425373-How-to-set-up-Surfshark-VPN-on-Raspberry-Pi-) en `<tu_repo>/vpn/yourfile.ovpn`

1. Crea un [fichero "pass"](https://www.ivpn.net/setup/linux-terminal/) para tomar las credenciales automaticamente en  `<tu_repo>/vpn/surfshark.pass`

1. Edita `yourfile.ovpn` como se indica en el link anterior para enlazar el fichero de credentiales.

1. Crea este script en `<tu_repo>/vpn/vpn_check.sh` 
    ```
    #!/bin/bash
    set -e

    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

    if [ "0" == `ifconfig | grep tun0 | wc -l` ]; 
    then 
        echo `date` No VPN!! Reconnecting
        sudo -b openvpn $SCRIPT_DIR/es-mad-surfshark.ovpn   # (if the ovpn file contains auth-user-pass)
        # sudo -b openvpn --config $SCRIPT_DIR/es-mad-surfshark.ovpn --auth-user-pass $SCRIPT_DIR/surfshark.pass
    else
        echo `date` VPN still up 
    fi
    ```
1. Crea un cron que lo ejecute
    > */15 0 * * *  /home/pi/repos/raspberry/plex/vpn/vpn_check.sh >> /home/pi/vpn_cron.log 2>&1

### Script de inicio
Puedes poner este script en tu home para iniciar el servicio mas rápido
```
#!/bin/bash
set -e

cd ~/repos/raspberry/plex 

case $1 in
"start")
	cd vpn && bash vpn_check.sh & 	# Needs to cd into vpn to take the right path for the .pass file
	docker-compose up -d
	;;
"stop")
	docker-compose down
	;;
*)
	echo "Argumentos validos: start|stop"
	;;
esac
```

## Pruebas 
(descrito en el video tutorial):

1. Descarga la pelicula gratuita "[Big Buck Bunny](
magnet:?xt=urn:btih:dd8255ecdc7ca55fb0bbf81323d87062db1f6d1c&dn=Big%20Buck%20Bunny%20%282008%29&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337&tr=udp%3A%2F%2Fexplodie.org%3A6969&tr=udp%3A%2F%2Ftracker.empire-js.us%3A1337&ws=https%3A%2F%2Fwebtorrent.io%2Ftorrents%2F)"

1. Ejecuta flexget para mueva el fichero a Plex
> docker-compose exec flexget flexget execute --dump --tasks sort_tv (or sort_movies)

1. Si necesitas relanzar el comando, primero necesitas que flexget "olvide" que ya lo hizo
> docker-compose exec flexget flexget seen forget file:///downloads/complete/Big%20Buck%20Bunny%20%282008%29/Big%20Buck%20Bunny.mp4 

## Troubleshooting

1. Si algo falla utiliza los logs `docker-compose logs flexget`

