#!/bin/bash

# echo "Bonjour" >> bonjour.txt

FTP_SERVER_IP=${FTP_SERVER_IP:-vsftpd}
FTP_SERVER_PORT=${FTP_SERVER_PORT:-21}
FTP_USER=${FTP_USER:-test}
FTP_PASS=${FTP_PASS:-pass}

echo "Uploading ..."

ftp -nv ${FTP_SERVER_IP} <<END_SCRIPT
quote USER ${FTP_USER}
quote PASS ${FTP_PASS}
put testfile.txt
quit