#!/bin/bash

# Define default values of Environment Variables
FTP_UID=${FTP_UID:-431}
FTP_GID=${FTP_GID:-433}
FTP_USER=${FTP_USER:-user}
FTP_PASS=${FTP_PASS:-pass}
PASV_ENABLE=${PASV_ENABLE:-YES}
PASV_ADDRESS=${PASV_ADDRESS:-}
PASV_ADDRESS_INTERFACE=${PASV_ADDRESS_INTERFACE:-eth0}
PASV_ADDR_RESOLVE=${PASV_ADDR_RESOLVE:-NO}
PASV_MIN_PORT=${PASV_MIN_PORT:-21100}
PASV_MAX_PORT=${PASV_MAX_PORT:-21110}
FTP_MODE=${FTP_MODE:-ftp}
LOG_STDOUT=${LOG_STDOUT:-NO}

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
addgroup -g $FTP_GID -S $FTP_USER
adduser -u $FTP_UID -D -G $FTP_USER -h /home/vsftpd -s /bin/false  $FTP_USER
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd
chown -R $FTP_USER:$FTP_USER /home/vsftpd/

# Building the configuration file
VSFTPD_CONF=/etc/vsftpd/vsftpd.conf
more /etc/vsftpd/vsftpd-base.conf > $VSFTPD_CONF

if [[ "$FTP_MODE" =~ ^(ftp|ftps|ftps_implicit|ftps_tls)$ ]]; then
  echo "FTP mode is $FTP_MODE"
  more /etc/vsftpd/vsftpd-${FTP_MODE}.conf >> $VSFTPD_CONF
else
  echo "$FTP_MODE is not a supported FTP mode"
  echo "FTP_MODE env var must be ftp, ftps, ftps_implicit or ftps_tls"
  echo "exiting"
  exit 1
fi

# Update the vsftpd-ftp.conf according to env variables
echo "Update the vsftpd.conf according to env variables"
echo "" >> $VSFTPD_CONF
echo "# the following config lines are added by the run-vsftpd.sh script for passive mode" >> $VSFTPD_CONF
echo "anonymous_enable=NO" >> $VSFTPD_CONF
echo "pasv_enable=$PASV_ENABLE" >> $VSFTPD_CONF
echo "pasv_address=$PASV_ADDRESS" >> $VSFTPD_CONF
echo "pasv_addr_resolve=$PASV_ADDR_RESOLVE" >> $VSFTPD_CONF
echo "pasv_max_port=$PASV_MAX_PORT" >> $VSFTPD_CONF
echo "pasv_min_port=$PASV_MIN_PORT" >> $VSFTPD_CONF

# Get log file path
export LOG_FILE=`grep ^vsftpd_log_file $VSFTPD_CONF | cut -d= -f2`

cat << EOB
  ********************************************************
  *                                                      *
  *    Docker image: lhauspie/vsftd-alpine               *
  *    https://github.com/lhauspie/docker-vsftpd-alpine  *
  *                                                      *
  ********************************************************

  SERVER SETTINGS
  ---------------
  . FTP_USER: "${FTP_USER}"
  . FTP_PASS: "${FTP_PASS}"
  . PASV_ENABLE: "${PASV_ENABLE}"
  . PASV_ADDRESS: "${PASV_ADDRESS}"
  . PASV_ADDRESS_INTERFACE: "${PASV_ADDRESS_INTERFACE}"
  . PASV_ADDR_RESOLVE: "${PASV_ADDR_RESOLVE}"
  . PASV_MIN_PORT: "${PASV_MIN_PORT}"
  . PASV_MAX_PORT: "${PASV_MAX_PORT}"
  . FTP_MODE: "${FTP_MODE}"
  . LOG_STDOUT: "${LOG_STDOUT}"
  . LOG_FILE: "${LOG_FILE}"
EOB

if [[ "${LOG_STDOUT}" == "YES" ]]; then
  touch ${LOG_FILE}
  tail -f ${LOG_FILE} >> /dev/stdout &
elif [[ "${LOG_STDOUT}" != "NO" ]]; then
  echo "LOG_STDOUT available options are 'YES' or 'NO'"
  exit 1
fi

# Run the vsftpd server
echo "Running vsftpd"
/usr/sbin/vsftpd $VSFTPD_CONF