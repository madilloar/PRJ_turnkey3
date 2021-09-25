# PRJ_turnkey3

MVS38j turnkey3 docker project

## 事前準備
herculesコンテナをビルド。
```
docker build -f hercules/Dockerfile .
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

## マスターコンソールを起動
turnkey3のコンテナイメージには``c3270``エミュレータを同梱しているので、docker runでエミュレータを起動している。
turnkey3のIPアドレスは``docker network inspect``で調べるて変更する。
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

## herculesエミュレータ起動時のワーニングについて
https://hercdoc.glanzmann.org/V311/HerculesMessagesandCodes.pdf
```
HHCTT001W Timer thread set priority -20 failed: Permission denied
```
confファイルのTODPRIOが-20となってるのを変更すれば変わる。
```
  TODPRIO     1                 # TOD Clock and timer thread are Time Critical
```

## コンテナビルドで嵌ったこと
課題:isoイメージをコンテナビルド時に``COPY``しても、``mount``ができない(``mount``には``root``権限が必要)。
対応:あらかじめホストOS側で``mount``しておいて、ディレクトリをごっそり``COPY``するように``Dockerfile``を作る。

課題:コンテナビルド時にturnkey3を``setup``してしまうと、コンテナイメージの中にmvs38jのデータセットが展開されてしまうため。コンテナ起動の都度データセットが初期化されてしまう。
対応:``Dockerfile``では``/tmp``以下にisoイメージをコピーするまでとして、``docker_entrypoint.sh``でturnkey3を``setup``する。

課題:単純に``docker_entrypoint.sh``でturnkey3を``setup``してしまうと、コンテナ起動の都度``setup``してしまう。
対応:setupが成功すると、``/opt/hercules/mvs38j/conf/turnkey_mvs.conf``ファイルができるので、このファイルが存在していたら、``setup``しないようにする。こんな感じ。
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
