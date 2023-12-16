#!/bin/bash

SAVE_NAME="CHANGEME"
SERVER_NAME="CHANGEME"
SERVER_PASSWORD="CHANGEME"
ADMIN_PASSWORD="CHANGEME"
WORLD="mars"
RESPAWN_CONDITION="stationeer"
MAX_PLAYERS=4
SAVE_INTERVAL=600
GAME_PORT=27016
UPDATE_PORT=27015

BASE_DIR="${HOME}/.steam/steamcmd"
STEAMCMD="${BASE_DIR}/steamcmd.sh"
SERVER_DIR="${HOME}/.steam/steamcmd/stationeers_ds"
SERVER_APP_ID=600760
TMUX_SESSION="stationeers-ds"

SERVER_START_PARAMS="-loadlatest ${SAVE_NAME} ${WORLD} -settings StartLocalHost true ServerVisible true GamePort ${GAME_PORT} UpdatePort ${UPDATE_PORT} AutoSave true AutoPauseServer false SaveInterval ${SAVE_INTERVAL} RespawnCondition ${RESPAWN_CONDITION} ServerName ${SERVER_NAME} ServerMaxPlayers ${MAX_PLAYERS} ServerPassword ${SERVER_PASSWORD} AdminPassword ${ADMIN_PASSWORD} LocalIpAddress 0.0.0.0"

if [ ! -d "${BASE_DIR}" ]; then
    mkdir -p "${BASE_DIR}"
    cd "${BASE_DIR}"
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
fi

install() {
    "${STEAMCMD}" +login anonymous +force_install_dir "${SERVER_DIR}" +app_update "${SERVER_APP_ID}" validate +quit
}

start() {
    tmux new-session -d -s "${TMUX_SESSION}" 
    tmux send -t "${TMUX_SESSION}" "${SERVER_DIR}/rocketstation_DedicatedServer.x86_64 ${SERVER_START_PARAMS}" ENTER
}

stop() {
    tmux send -t "${TMUX_SESSION}" save "${SAVE_NAME}" ENTER
    sleep 5
    tmux send -t "${TMUX_SESSION}" quit ENTER
    sleep 30
    if tmux has-session -t "${TMUX_SESSION}" > /dev/null 2>&1; then
        tmux kill-session -t "${TMUX_SESSION}"
    fi
}

update() {
    install

    if tmux has-session -t "${TMUX_SESSION}" > /dev/null 2>&1; then
        stop
        sleep 5
        start
    fi
}

case "$1" in
    install) install ;;
    start) start ;;
    stop) stop ;;
    update) update ;;
    *) 
        echo "Usage: $0 {install|start|stop|update}"
        exit 1
esac

exit 0