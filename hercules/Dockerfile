FROM ubuntu:latest
ENV HERCULES_HOME /opt/hercules

WORKDIR $HERCULES_HOME

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  vim wget \
  c3270 \
  zlib1g-dev libbz2-dev \
  autoconf automake gawk gcc g++ m4 make && \
## 
  wget -q http://downloads.hercules-390.eu/hercules-3.13.tar.gz -O /tmp/hercules.tar.gz && \
  echo "hercules.tar.gz Hash: $(md5sum /tmp/hercules.tar.gz)" >> /tmp/MD5SUMS && \
  echo "hercules.tar.gz Date: $(date)" >> /tmp/MD5SUMS && \
  cat /tmp/MD5SUMS && \
##
  mkdir -p /tmp/hercules && \
  tar xvzf /tmp/hercules.tar.gz -C /tmp/hercules --strip-components 1 && \
  cd /tmp/hercules && \
  ./configure --prefix=$HERCULES_HOME && \
  make && \
  make install && \
  mkdir -p $HERCULES_HOME/bin/util && \
  cp ./util/zzsacard.bin $HERCULES_HOME/bin/util/zzsacard.bin && \
##
  apt-get purge -y --auto-remove  autoconf automake gawk gcc g++ m4 make && \
  apt-get clean && \
  rm -rf /tmp/hercules && \
  rm -rf /tmp/hercules.tar.gz && \
  rm -rf /var/lib/apt/lists/*

