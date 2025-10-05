🧩 Práctica: Dockerizar una web estática y publicarla en Docker Hub
👤 Autor
Nombre: Bryan Peguero
Usuario Docker Hub: lulon13
Repositorio GitHub: https://github.com/lulon13/nginx-2048


💡 Descripción
En esta práctica se dockerizó una web estática (el juego 2048) utilizando Nginx como servidor web.
Después se construyó la imagen, se publicó en Docker Hub bajo el usuario lulon13, y se automatizó con GitHub Actions para que cada vez que se suban cambios, la imagen se genere y publique automáticamente.
Por último, se desplegó en una instancia EC2 de AWS usando Docker Compose.


🧱 1. Creación del Dockerfile
Primero se creó un archivo Dockerfile con la configuración necesaria para instalar Ubuntu, Nginx y Git, y clonar el juego 2048 en el directorio /var/www/html.
Código:

FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg tzdata; \
    rm -rf /var/lib/apt/lists/*
RUN set -eux; \
    for i in 1 2 3; do \
      apt-get update -y && apt-get install -y --no-install-recommends nginx git && break || sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/www/html/* && \
    git -c http.sslVerify=true clone --depth 1 https://github.com/josejuansanchez/2048 /var/www/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


🧩 2. Construcción y prueba local
Después se creó la imagen Docker y se probó localmente con los siguientes comandos:

docker build -t nginx-2048 .
docker run --rm -p 8080:80 nginx-2048

Luego se abrió el navegador en http://localhost:8080 y se verificó que el juego 2048 cargara correctamente.

🚀 3. Publicación en Docker Hub
Una vez construida la imagen, se etiquetó y se subió al perfil de Docker Hub (lulon13):

docker tag nginx-2048 lulon13/nginx-2048:1.0
docker tag nginx-2048 lulon13/nginx-2048:latest
docker login
docker push lulon13/nginx-2048:1.0
docker push lulon13/nginx-2048:latest


🔗 Enlace a Docker Hub:
https://hub.docker.com/r/lulon13/nginx-2048

⚙️ 4. Automatización con GitHub Actions
Para automatizar la subida de la imagen a Docker Hub, se creó el archivo:
.github/workflows/docker-publish.yml
Código del workflow:

name: Build & Push to Docker Hub

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate DOCKERHUB_TOKEN
        run: |
          test -n "${{ secrets.DOCKERHUB_TOKEN }}" || (echo "❌ DOCKERHUB_TOKEN is empty" && exit 1)
          echo "✅ DOCKERHUB_TOKEN presente"

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: lulon13
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            lulon13/nginx-2048:latest
            lulon13/nginx-2048:1.0
            
Se creó el secret DOCKERHUB_TOKEN en el repositorio con el Access Token de Docker Hub.
Luego, al hacer un git push, el workflow se ejecutó automáticamente y subió la imagen correctamente a Docker Hub.

🌐 5. Despliegue en AWS EC2
Después se creó una instancia Ubuntu 22.04 en AWS EC2, se instalaron Docker y Docker Compose, y se hizo el despliegue con el siguiente archivo:

docker-compose.yml
services:
  nginx-2048:
    image: lulon13/nginx-2048:latest
    ports:
      - "80:80"
    restart: unless-stopped
    
Comandos usados en EC2:

docker compose up -d
docker ps

Luego se accedió desde el navegador usando la IP pública de la instancia para verificar que el juego funcionara correctamente:

👉 Ejemplo: http://3.17.59.176

