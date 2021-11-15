# OpenLDAP server with phpLDAPAdmin

The Lightweight Directory Access Protocol (LDAP) is an open, vendor-neutral,
industry standard application protocol for accessing and maintaining
distributed directory information services over an Internet Protocol (IP)
network.

This image is based on Alpine Linux, OpenLDAP and phpLDAPAdmin

[![GitHub Workflow - CI](https://github.com/mailsvb/ldap-alpine/workflows/build/badge.svg)](https://github.com/mailsvb/ldap-alpine/actions?workflow=build)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/mailsvb/ldap-alpine)](https://github.com/mailsvb/ldap-alpine/releases/latest)
[![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/mailsvb/ldap?sort=semver)](https://hub.docker.com/repository/docker/mailsvb/ldap)

## Customisation

Override the following environment variables when running the docker container
to customise LDAP:

| VARIABLE | DESCRIPTION | DEFAULT |
| :------- | :---------- | :------ |
| ORGANISATION_NAME | Organisation name | Test |
| SUFFIX | Organisation distinguished name | dc=test,dc=local |
| ROOT_USER | Root username | admin |
| ROOT_PW | Root password | password |
| ACCESS_CONTROL | Global access control | access to * by * read |
| LOG_LEVEL | LDAP logging level, see below for valid values. | stats |

For example:

```
docker run -dit -p 80:80 -p 389:389 -p 636:636 --restart unless-stopped --name openldap \
  -e ORGANISATION_NAME="Test" \
  -e SUFFIX="dc=test,dc=local" \
  -e ROOT_USER="admin" \
  -e ROOT_PW="password" \
  mailsvb/ldap:latest
```

## Logging Levels

| NAME | DESCRIPTION |
| :--- | :---------- |
| any | enable all debugging (warning! lots of messages will be output) |
| trace | trace function calls |
| packets | debug packet handling |
| args | heavy trace debugging |
| conns | connection management |
| BER | print out packets sent and received |
| filter | search filter processing |
| config | configuration processing |
| ACL | access control list processing |
| stats | stats log connections/operations/results |
| stats2 | stats log entries sent |
| shell | print communication with shell backends |
| parse | print entry parsing debugging |
| sync | syncrepl consumer processing |
| none | only messages that get logged whatever log level is set |

## Persist data

The container uses a standard mdb backend. To persist this database outside the
container mount `/var/lib/openldap/openldap-data`. For example:

```
docker run run -t -p 389:389 \
  --mount source=openldap-data,target=/var/lib/openldap/openldap-data \
  mailsvb/ldap:latest
```

## Transport Layer Security

The container can be started using the encrypted LDAPS protocol. You must
provide all three TLS environment variables.

| VARIABLE | DESCRIPTION | EXAMPLE |
| :------- | :---------- | :------ |
| CA_FILE | PEM-format file containing certificates for the CA's that slapd will trust | /etc/ssl/certs/ca.pem |
| KEY_FILE | The slapd server private key | /etc/ssl/certs/public.key |
| CERT_FILE | The slapd server certificate | /etc/ssl/certs/public.crt |

Note these variables inform the entrypoint script (executed on startup) where
to find the SSL certificates inside the container. So the certificates must
also be mounted at runtime too, for example:

```
docker run -t -p 389:389 \
  -v /my-certs:/etc/ssl/certs \
  -e CA_FILE /etc/ssl/certs/ca.pem \
  -e KEY_FILE /etc/ssl/certs/public.key \
  -e CERT_FILE /etc/ssl/certs/public.crt \
  mailsvb/ldap:latest
```

Where `/my-certs` on the host contains the three certificate files `ca.pem`,
`public.key` and `public.crt`.

To disable client certificates set `TLS_VERIFY_CLIENT` to `never` or `try`.

## Access Control

Global access to your directory can be configured via the ACCESS_CONTROL environment variable.

The default policy allows anyone and everyone to read anything but restricts updates to rootdn.

```
access to * by * read
```

Note rootdn can always read and write *everything*!

You can find detailed documentation on access control here https://www.openldap.org/doc/admin24/access-control.html

This following access control allows the user to modify their entry, allows anonymous to authenticate against these entries,
and allows all others to read these entries:

```
docker run -t -p 389:389 \
  -e ACCESS_CONTROL="access to * by self write by anonymous auth by users read" \
  mailsvb/ldap:latest
```

Now `ldapsearch -x -b "dc=example,dc=com" "uid=pgarret"` will return no results.

In order to search you will need to authenticate (bind) first:

```
ldapsearch -D "uid=pgarrett,ou=Users,dc=example,dc=com" -w password -b "dc=example,dc=com" "uid=pgarrett"
```
