FROM alpine

ENV ORGANISATION_NAME "Test"
ENV SUFFIX "dc=test,dc=local"
ENV ROOT_USER "admin"
ENV ROOT_PW "password"
ENV ACCESS_CONTROL "access to * by * read"
ENV LOG_LEVEL "stats"

RUN apk update && apk upgrade
RUN apk add openldap openldap-back-mdb apache2 php7-apache2 git ca-certificates supervisor openssl php7 php7-openssl php7-session php7-gettext php7-ldap php7-xml && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /run/openldap /var/lib/openldap/openldap-data

RUN git clone https://github.com/breisig/phpLDAPadmin.git /var/www/html

RUN sed -i "s#^DocumentRoot \".*#DocumentRoot \"/var/www/html\"#g" /etc/apache2/httpd.conf && \
    sed -i "s#/var/www/localhost/htdocs#/var/www/html#" /etc/apache2/httpd.conf && \
    sed -i "s/#ServerName\ www.example.com:80/ServerName\ phpldapadmin:80/g" /etc/apache2/httpd.conf && \
    printf "\n<Directory \"/var/www/html\">\n\tAllowOverride All\n</Directory>\n" >> /etc/apache2/httpd.conf
COPY config.php /var/www/html/config
RUN chown -R apache:apache /var/www

COPY scripts/* /etc/openldap/
COPY docker-entrypoint.sh /
COPY supervisord.conf /etc/supervisord.conf

RUN dos2unix /docker-entrypoint.sh

EXPOSE 80
EXPOSE 389
EXPOSE 636

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
