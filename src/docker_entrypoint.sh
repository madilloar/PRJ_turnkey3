#!/bin/sh
FILE="/opt/hercules/mvs38j/conf/turnkey_mvs.conf"

if [ ! -e ${FILE} ]; then
	  cd /tmp/src/media && \
		    echo -e "\n1\n/opt/hercules/mvs38j\n3\nY\nY\nY\nY\n3270\n3505\n8081\n2\nY\n\n1\n1\n32\nY\n\nSECRET\n\n\n" | ./setup && \
		      cd /opt/hercules/mvs38j
fi
exec "$@"

