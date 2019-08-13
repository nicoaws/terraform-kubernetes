FROM nginx:latest

RUN \
  apt-get update && \
  apt-get -y install inetutils-ping curl tcpdump dnsutils

# # Define mountable directories.
# VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]

# # Define working directory.
# WORKDIR /etc/nginx

# # Define default command.
# CMD ["nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443