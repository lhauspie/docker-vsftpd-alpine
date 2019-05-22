FROM alpine:3.9.4

MAINTAINER Logan HAUSPIE <logan.hauspie.pro@gmail.com>
LABEL Description="vsftpd Docker image based on Alpine. Supports passive mode and virtual users." \
	License="Apache License 2.0" \
	Usage="docker run --rm -it --name vsftpd -p [HOST_CONNECTION_PORTS]:20-22 -p [HOST_FTP_PORTS]:21100-21110 lhauspie/vsftpd-alpine" \
	Version="${VERSION}"

# RUN apk update and install dependencies
RUN apk update \
		&& apk upgrade \
		&& apk --update --no-cache add \
				bash \
				vsftpd 

ENV FTP_USER=user \
    FTP_PASS=pass \
    PASV_ENABLE=YES \
    PASV_ADDRESS= \
		PASV_ADDRESS_INTERFACE=eth0 \
		PASV_ADDR_RESOLVE=NO \
    PASV_MIN_PORT=21100 \
    PASV_MAX_PORT=21110

RUN mkdir -p /home/vsftpd/
RUN chown -R ftp:ftp /home/vsftpd/

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY run-vsftpd.sh /usr/sbin/
RUN chmod +x /usr/sbin/run-vsftpd.sh

EXPOSE 20-22 21100-21110

CMD /usr/sbin/run-vsftpd.sh
