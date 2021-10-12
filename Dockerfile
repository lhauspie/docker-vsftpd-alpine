FROM alpine:3.9.4

MAINTAINER Logan HAUSPIE <logan.hauspie.pro@gmail.com>
LABEL Description="vsftpd Docker image based on Alpine. Supports passive mode and virtual users." \
	License="GNU General Public License v3" \
	Usage="docker run --rm -it --name vsftpd -p [HOST_CONNECTION_PORTS]:20-22 -p [HOST_FTP_PORTS]:21100-21110 lhauspie/vsftpd-alpine" \
	Version="${VERSION}"

# RUN apk update and install dependencies
RUN apk update \
		&& apk upgrade \
		&& apk --update --no-cache add \
				bash \
				openssl \
				vsftpd 

RUN openssl req -x509 -nodes -days 7300 \
            -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem \
            -subj "/C=FR/O=My company/CN=example.org"

RUN mkdir -p /home/vsftpd/
RUN mkdir -p /var/log/vsftpd
RUN chown -R ftp:ftp /home/vsftpd/

COPY vsftpd-base.conf /etc/vsftpd/vsftpd-base.conf
COPY vsftpd-ftp.conf /etc/vsftpd/vsftpd-ftp.conf
COPY vsftpd-ftps.conf /etc/vsftpd/vsftpd-ftps.conf
COPY vsftpd-ftps_implicit.conf /etc/vsftpd/vsftpd-ftps_implicit.conf
COPY vsftpd-ftps_tls.conf /etc/vsftpd/vsftpd-ftps_tls.conf
COPY run-vsftpd.sh /usr/sbin/
RUN chmod +x /usr/sbin/run-vsftpd.sh

EXPOSE 20-22 990 21100-21110

CMD /usr/sbin/run-vsftpd.sh
