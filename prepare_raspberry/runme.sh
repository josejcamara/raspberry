# Instalar paquetes necesarios
sudo apt-get update && sudo apt-get install -y \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common \
     vim \
     fail2ban \
     ntfs-3g

# Instalar firmas GPG del repo de Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

# Agregar repo de Docker a las apt-sources
echo "deb [arch=armhf] https://download.docker.com/linux/debian \
     $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list
    
# NOTA: las versiones de docker mayores a 18.06 estaan presentando problemas sobre raspbian. 
# Si encuentran problemas de "Segmentation fault" o que el demonio no inicia, pueden evitar que versiones superiores se instalen de la siguiente forma
# echo "Package: docker-ce
# Pin: version 18.06.1*
# Pin-Priority: 1000" > /etc/apt/preferences.d/docker-ce

# Instalar Docker
sudo apt-get update && sudo apt-get install -y --no-install-recommends docker-ce docker-compose

# Agregar usuario al grupo docker para correr docker sin user root
sudo usermod -a -G docker pi
#(logout and login)

# Arrancar docker al inicio
sudo systemctl enable docker

