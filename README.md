# PRJ_turnkey3
MVS38j turnkey3 docker project

## 事前準備
isoイメージをコンテナビルド時にCOPYしても、mountができないので、あらかじめホストOSでmountしておいて、ディレクトリをごっそりCOPYする。
```
#!/bin/bash
MYHOME=~/prj/turnkey3
TK3="turnkey-mvs-3"
CDROM="${MYHOME}/cdrom"

cd ${MYHOME}

if [ ! -e ${TK3}.zip ] ; then
  wget http://www.ibiblio.org/jmaynard/${TK3}.zip
  unzip ${TK3}.zip
fi

mkdir -p ${CDROM}
read -sp "Please sudo password:" PASSWORD
tty -s && echo
echo ${PASSWORD} | sudo -S mount -r ${TK3}.iso ${CDROM}

cp -r ${CDROM} ./src
echo ${PASSWORD} | sudo -S umount ${CDROM}
rm -rf ${CDROM}

chmod -R u+w ${MYHOME}/src/cdrom
rm -rf ${MYHOME}/src/media
mv ${MYHOME}/src/cdrom/ ${MYHOME}/src/media/

docker-compose build
```

## Dockerfile
コンテナを実行するたびにturnkey3のデータセットの状態が初期状態になるのは困るので、Dockerfileでは/opt/hercules/mvs38jにデータセットやその他の定義ファイルをコピーしない。
```
vi ~/prj/turnkey3/Dockerfile
```
```
FROM hercules:1
WORKDIR /opt/hercules/mvs38j
COPY src /tmp/src
RUN mkdir -p /opt/hercules/mvs38j && \
  cp -p /tmp/src/docker_entrypoint.sh /opt/hercules/mvs38j && \
  cp -p /tmp/src/startmvs /tmp/src/media/conf/_startmvs && \
  cp -p /tmp/src/c3270.keymap /opt/hercules/mvs38j

ENTRYPOINT  ["./docker_entrypoint.sh"]
```

## docker_entrypoint.sh
コンテナ実行時にVOLUMEが接続されるので、このエントリポイントshellでデータセットやconfファイルのセットアップをしている。

if文を入れいているのは、confファイルが存在しない場合、つまり一度もセットアップしていない場合は、セットアップし、そうでない場合は何もしないため。
```
vi ~/prj/turnkey3/src/docker_entrypoint.sh
```
```
#!/bin/sh
FILE="/opt/hercules/mvs38j/conf/turnkey_mvs.conf"

if [ ! -e ${FILE} ]; then
  cd /tmp/src/media && \
  echo -e "\n1\n/opt/hercules/mvs38j\n3\nY\nY\nY\nY\n3270\n3505\n8081\n2\nY\n\n1\n1\n32\nY\n\nSECRET\n\n\n" | ./setup && \
  cd /opt/hercules/mvs38j
fi
exec "$@"
```
```
chmod u+x ~/prj/turnkey3/src/docker_entrypoint.sh
```

## startmvs
mvs38jの起動スクリプト。
```
vi ~/prj/turnkey3/src/startmvs
```
```
#!/bin/sh
/opt/hercules/bin/hercules -f /opt/hercules/mvs38j/conf/turnkey_mvs.conf
```
```
chmod u+x ~/prj/turnkey3/src/startmvs
```

## c3270.keymap

```~/prj/turnkey3/src/c3270.keymap
<Key>PPAGE: PA(2)
<Key>NPAGE: PA(1)
<Key>FIND: Home
<Key>SELECT: EraseEOF
```

## docker-compose.yml
```
vi ~/prj/turnkey3/docker-compose.yml
```
```
version: '3.7'

services:
  turnkey3:
    build: .
    volumes:
      - mvs38j:/opt/hercules/mvs38j
    environment:
      - TZ=Japan/Tokyo
    ports:
      - 8081:8081
      - 3270:3270

volumes:
  mvs38j:
```

## turnkey3イメージのビルド
```
docker-compose build
```
```
docker build . -t turnkey:1
```

## turnkey3でmvsを起動
```
docker-compose run turnkey3 ./startmvs
```
```
docker run --rm -it -v mvs38j:/opt/hercules/mvs38j -p 3270:3270 -p 8081:8081 --name c_turnkey_1 turnkey:1 ./startmvs
```

## マスターコンソール
```
docker-compose run turnkey3 c3270 -charset us-intl -model 3278-2 -keymap c3270.keymap 172.29.0.2:3270
```
## 一般ユーザ

```
docker-compose run turnkey3 c3270 -charset us-intl -model 3279-2 -keymap c3270.keymap 172.29.0.2:3270
```

## HERCULESエミュレータで
```
IPL 148
```

## マスタコンソールで
```
R 00,CLPA
R 00,Y
S JES2
R 01,FORMAT,NOREQ
R 02,Y
R 03,Y
```

## 一般ユーザで
```
HERC01
RPF
LOGOFF
```
``Ctrl+]``でc3270のモードを切り替え、``exit``と入力し、``Enterキー``を押下し、shellに戻る。
```
Press <Enter> to resume session.
c3270>exit
```


## マスターコンソールで
```
f bsppilot,shutnow
$PJES2
```
## HERCULEエミュレータで
```
STOP
QUIT
```

## その他覚書
### c3270で接続するときのIPアドレスを調べる 
```
docker network ls
docker network inspect turnkey3_default
```

### docker volumeを削除して更地にする
```
docker volume ls
```
```
docker volume rm turnkey3_mvs38j
```

### shellを起動して手動で何かするとき
```
docker-compose run turnkey3 sh
```
```
docker run --rm -it turnkey:1 sh
```

# herculesエミュレータ起動時のワーニングについて
https://hercdoc.glanzmann.org/V311/HerculesMessagesandCodes.pdf
```
HHCTT001W Timer thread set priority -20 failed: Permission denied
```
hercules.cnfの69行目のTODPRIOが-20となってるのを変更すれば変わる。
```
  TODPRIO     1                 # TOD Clock and timer thread are Time Critical
```

