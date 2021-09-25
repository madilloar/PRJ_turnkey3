FROM hercules:1
WORKDIR /opt/hercules/mvs38j
COPY src /tmp/src
RUN mkdir -p /opt/hercules/mvs38j && \
  cp -p /tmp/src/docker_entrypoint.sh /opt/hercules/mvs38j && \
  cp -p /tmp/src/startmvs /tmp/src/media/conf/_startmvs && \
  cp -p /tmp/src/c3270.keymap /opt/hercules/mvs38j && \
  cp -p /tmp/src/master_user.sh /opt/hercules/mvs38j && \
  cp -p /tmp/src/tso_user.sh /opt/hercules/mvs38j && \
  tic /tmp/src/xterm_my.src

ENTRYPOINT  ["./docker_entrypoint.sh"]
