FROM ubuntu:latest
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /var/www/html/*

RUN git clone https://github.com/josejuansanchez/2048 /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

