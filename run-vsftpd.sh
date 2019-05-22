#!/bin/bash

# You can set PASV_ADDRESS_INTERFACE to the name of the interface you'd like to
# bind to and this will look up the IP and set the proper PASV_ADDRESS value.
if [ -z "$PASV_ADDRESS" ]; then
  echo "PASV_ADDRESS env variable is not set"
  if [ -n "$PASV_ADDRESS_INTERFACE" ]; then
	echo "attempt to guess the PASV_ADDRESS from PASV_ADDRESS_INTERFACE"
    PASV_ADDRESS=$(ip -o -4 addr list $PASV_ADDRESS_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
    if [ -z "$PASV_ADDRESS" ]; then
      echo "Could not find IP for interface '$PASV_ADDRESS_INTERFACE', exiting"
      exit 1
    fi
    echo "==> Found address '$PASV_ADDRESS' for interface '$PASV_ADDRESS_INTERFACE', setting PASV_ADDRESS env variable..."
  fi
else
  echo "PASV_ADDRESS is set so we use it directly"
fi

# Add the FTP_USER, change his password and declare him as the owner of his home folder and all subfolders
addgroup -g 433 -S $FTP_USER
adduser -u 431 -D -G $FTP_USER -h /home/vsftpd/$FTP_USER -s /bin/false  $FTP_USER
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd
chown -R $FTP_USER:$FTP_USER /home/vsftpd/$FTP_USER


# Update the vsftpd.conf according to env variables
sed -i "s/anonymous_enable=YES/anonymous_enable=NO/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_enable=.*/pasv_enable=$PASV_ENABLE/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_address=.*/pasv_address=$PASV_ADDRESS/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_addr_resolve=.*/pasv_addr_resolve=$PASV_ADDR_RESOLVE/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_max_port=.*/pasv_max_port=$PASV_MAX_PORT/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_min_port=.*/pasv_min_port=$PASV_MIN_PORT/" /etc/vsftpd/vsftpd.conf


# Run the vsftpd server
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf