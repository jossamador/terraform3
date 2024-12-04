terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token

}

# Crear el Droplet
resource "digitalocean_droplet" "api_server" {
  name   = "api-server"
  region = "nyc3"  # Cambia a tu región preferida
  size   = "s-1vcpu-1gb"  # Tamaño del Droplet
  image  = "ubuntu-20-04-x64"  # Imagen del sistema operativo
  ssh_keys = ["ee:0c:27:3b:47:1c:63:2a:89:01:ca:d9:75:d9:c2:2e"]  # Reemplaza con tu clave SSH
  user_data = <<EOF
#!/bin/bash
# Actualiza los paquetes
apt-get update -y && apt-get upgrade -y

# Instala Docker
apt-get install -y docker.io docker-compose

# Habilita Docker
systemctl enable docker
systemctl start docker

# Crea los directorios de la API
mkdir -p /home/api
cd /home/api

# Descarga un archivo docker-compose.yml desde un repositorio público o desde tus assets
cat > docker-compose.yml <<EOL
version: '3'
services:
  api:
    image: <usuario>/api-productos:latest # Cambia esto por tu imagen en Docker Hub
    ports:
      - "4000:4000"
    environment:
      - MONGO_URI=mongodb://mongo:27017/api_productos
    depends_on:
      - mongo
  mongo:
    image: mongo:latest
    volumes:
      - mongodb_data:/data/db
volumes:
  mongodb_data:
EOL

# Ejecuta el docker-compose
docker-compose up -d
EOF
}

# Crear un firewall para proteger el servidor
resource "digitalocean_firewall" "api_firewall" {
  name = "api-firewall"

  # Reglas de entrada
  inbound_rule {
    protocol         = "tcp"
    port_range       = "4000"
    source_addresses = ["0.0.0.0/0", "::/0"] # Permitir tráfico en el puerto 4000
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"] # Permitir acceso SSH
  }

  # Reglas de salida
  outbound_rule {
    protocol         = "tcp"
    port_range       = "all"
    destination_addresses = ["0.0.0.0/0"]
  }

  droplet_ids = [digitalocean_droplet.api_server.id]
}

# Salida para obtener la IP pública del Droplet
output "public_ip" {
  value       = digitalocean_droplet.api_server.ipv4_address
  description = "La IP pública del servidor"
}
