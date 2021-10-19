
![docker_logo](https://raw.githubusercontent.com/lhauspie/docker-vsftpd-alpine/master/images/docker.png)
![vsftpd_logo](https://raw.githubusercontent.com/lhauspie/docker-vsftpd-alpine/master/images/vsftpd.jpeg)

[![Docker Pulls](https://img.shields.io/docker/pulls/lhauspie/vsftpd-alpine.svg?type=plastic&logo=docker)](https://hub.docker.com/r/lhauspie/vsftpd-alpine/)
[![Docker Build Status](https://img.shields.io/docker/build/lhauspie/vsftpd-alpine.svg?type=plastic&logo=docker)](https://hub.docker.com/r/lhauspie/vsftpd-alpine/builds/)
[![](https://images.microbadger.com/badges/image/lhauspie/vsftpd-alpine.svg)](https://microbadger.com/images/lhauspie/vsftpd-alpine "lhauspie/vsftpd-alpine")

# Purpose

This Docker image is inpired by 3 other Docker images to merge all their fonctionalities in one unique image:
- [fauria/vsftpd](https://hub.docker.com/r/fauria/vsftpd)
- [loicmathieu/vsftpd](https://hub.docker.com/r/loicmathieu/vsftpd)
- [avenus/vsftpd-alpine](https://hub.docker.com/r/avenus/vsftpd-alpine)

This Docker container provides a [vsftpd server](https://doc.ubuntu-fr.org/vsftpd), with the following features:
- Alpine 3.9.4 base image.
- vsftpd 3.0.3
- Passive mode (disableable by env variable)
- Base the `pasv_address` on a network interface
- FTPS Explicit (over ftp/ftpes protocol and port 21)
- FTPS Implicit (over ftps protocol and port 990)
- FTPS TLS (whith strong protocol/cypher)
- Logging to STDOUT or file
- Ability to plug local folder to container volume

Comming soon:
- SFTP (FTP over SSH on port 22)
- Virtual users


# How to build ?

It's pretty simple to build the image from source thanks to the `Makefile`.

```bash
$ make build
```


# How to use ?

## Summary

Run the container:
```bash
$ docker run --rm -it --name vsftpd -p 20-22:20-22 -p 21100-21110:21100-21110 -p 990:990 lhauspie/vsftpd-alpine
```

Connect to the FTP server from the host machine:
```bash
$ ftp -p localhost 21
```

Connect to the FTP server from another container:
```bash
$ docker run -it --rm --link vsftpd centos:7 bash
$ yum install ftp
$ ftp -p vsftpd 21
```

If you want to make local files available in the remote folder of the ftp server, you can do as follows:
```
$ export FTP_USER=user

$ ll
-rw-r--r--@ 1 lhauspie  staff   3,3K 18 oct 18:34 docker-compose.yaml

$ docker run --rm -d -v $PWD:/home/vsftpd/$FTP_USER -v FTP_USER=$FTP_USER --name vsftpd -p 20-22:20-22 -p 21100-21110:21100-21110 -p 990:990 lhauspie/vsftpd-alpine
a454baca6b526faec2fa594ebd750deabf18c957d2cf408daefdcb8943cdbd2b

$ ftp -p $FTP_USER@localhost 21
Connected to localhost.
Password: 
230 Login successful.
ftp> ls
-rw-r--r--    1 431      433          3336 Oct 18 16:34 docker-compose.yaml
```

In addition, if you upload a file (with the command `send`) to the FTP server you will retrieve it in the local folder.

## Environment Variables

All the following environment variables have to be specified as docker environment variable like :
```
docker run -e ENV_VAR=env_val vsftpd-alpine
```
For more information, please refer to [docker env variables](https://docs.docker.com/engine/reference/run/#env-environment-variables)

### `FTP_USER`
Username for the default FTP account.

Default value: `user`  
Accepted values: Any string. Avoid whitespaces and special chars.


### `FTP_PASS`
This is the password of the default FTP account.

Default value: `pass`  
Accepted values: Any string. Avoid whitespaces and special chars.


### `FTP_MODE`
Allow you to choose which ftp configuration you want to use.

Default value: `ftp`  
Accepted values: < `ftp` | `ftps` | `ftps_implicit` | `ftps_tls` >

Note that in case of using `ftps_implicit` you must expose the port `990`.  
So don't forget to expose your ports with `docker -p` parameter.


### `PASV_ENABLE`
Allow you to enable/disable the passive mode of the FTP server.

Default value: `YES`  
Accepted values: < `NO` | `YES` >


### `PASV_ADDRESS`
This is the address sent by the FTP server to the client during a passive mode connection. If you choose to set this variable with a hostname, just be sure that this hostname is known by the docker container.

Default value: < EMPTY STRING >  
Accepted values: Any IPv4 address or Hostname (see `PASV_ADDR_RESOLVE`).


### `PASV_ADDRESS_INTERFACE`
Allow you to extract the IP address of a network interface to set the `PASV_ADDRESS` dynamically.  
Usefull when you want to connect to the FTP server from Host machine or from another container.

Default value: `eth0`  
Accepted values: Any IPv4 address or Hostname (see `PASV_ADDRESS_RESOLVE`).

`PASV_ADDRESS_INTERFACE` has no effect as soon as `PASV_ADDRESS` is set.
So the following command will set the `pasv_address` option to the IP of the container (network interface `eth0`):
```bash
$ docker run --rm -it --name vsftpd -e PASV_ADDRESS_INTERFACE=eth0 -p 21:21 -p 21100-21110:21100-21110 lhauspie/vsftpd-alpine
```
While the following command will set the `pasv_address` to `foobar`:
```bash
$ docker run --rm -it --name vsftpd -e PASV_ADDRESS=foobar -e PASV_ADDRESS_INTERFACE=eth0 -p 21:21 -p 21100-21110:21100-21110 lhauspie/vsftpd-alpine
```


### `PASV_ADDR_RESOLVE`
Set to `YES` if you want to use a hostname (as opposed to IP address) in the `PASV_ADDRESS` env variable.

Default value: `NO`  
Accepted values: < `NO` | `YES` >

To use the `PASV_ADDR_RESOLVE` env variable, you have to specify the `--hostname` docker run option with the same value as the env variable:
```bash
$ docker run --rm -it --hostname vsftpd --name vsftpd -e PASV_ADDRESS=vsftpd -e PASV_ADDR_RESOLVE=YES -p 21:21 -p 21100-21110:21100-21110 lhauspie/vsftpd-alpine
```


### `PASV_MIN_PORT`
This will be used as the lower bound of the passive mode port range.  
Don't forget to expose your ports with `docker -p` parameter.

Default value: `21100`  
Accepted values: Any valid port number


### `PASV_MAX_PORT`
This will be used as the upper bound of the passive mode port range.  
Don't forget to expose your ports with `docker -p` parameter.

Default value: `21110`  
Accepted values: Any valid port number


### `LOG_STDOUT`
Output vsftpd log through STDOUT, so that it can be accessed through the [container logs](https://docs.docker.com/reference/commandline/logs/).

Default value: `NO`  
Accepted values: < `NO` | `YES` >
