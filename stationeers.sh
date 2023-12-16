#!/bin/bash

SAVE_NAME='CHANGEME' # The name of the save file.
SERVER_NAME='CHANGEME' # What will your server be called in the listings?
SERVER_PASSWORD='CHANGEME'
ADMIN_PASSWORD='CHANGEME'
WORLD='mars' # moon | mars | europa | mimas | vulcan | venus
RESPAWN_CONDITION='Stationeer' # Easy | Normal | Stationeer
MAX_PLAYERS=4
SAVE_INTERVAL=600
GAME_PORT=27016
UPDATE_PORT=27015
SERVER_VISIBLE='true'
START_LOCALHOST='true'
AUTOSAVE='true'
AUTO_PAUSE='true'

BASE_DIR="${HOME}/.steam/steamcmd"
STEAMCMD="${BASE_DIR}/steamcmd.sh"
SERVER_DIR="${HOME}/.steam/steamcmd/stationeers_ds"
SERVER_APP_ID=600760
TMUX_SESSION="stationeers-ds"

SERVER_START_PARAMS="-loadlatest \"${SAVE_NAME}\" ${WORLD} -settings StartLocalHost ${START_LOCALHOST} ServerVisible ${SERVER_VISIBLE} GamePort ${GAME_PORT} UpdatePort ${UPDATE_PORT} AutoSave ${AUTOSAVE} AutoPauseServer ${AUTO_PAUSE} SaveInterval ${SAVE_INTERVAL} RespawnCondition ${RESPAWN_CONDITION} ServerName \"${SERVER_NAME}\" ServerMaxPlayers ${MAX_PLAYERS} ServerPassword \"${SERVER_PASSWORD}\" AdminPassword \"${ADMIN_PASSWORD}\" LocalIpAddress 0.0.0.0"

if [ ! -d "${BASE_DIR}" ]; then
    echo "SteamCMD is not installed... installing to ${BASE_DIR}"
    mkdir -p "${BASE_DIR}"
    cd "${BASE_DIR}"
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
    echo "SteamCMD installation complete - please check that SteamCMD installed correctly before continuing"
fi

install() {
    if [ ! -d "${BASE_DIR}" ]; then
        echo "Server is not installed... installing to ${SERVER_DIR}"
        "${STEAMCMD}" +login anonymous +force_install_dir "${SERVER_DIR}" +app_update "${SERVER_APP_ID}" validate +quit
        echo "Installation complete - please check that the server installed correctly before continuing"
    else
        echo "Updating server"
        "${STEAMCMD}" +login anonymous +force_install_dir "${SERVER_DIR}" +app_update "${SERVER_APP_ID}" validate +quit
        echo "Update complete"
    fi
}

start() {
    install # Update server on start

    # If it's already running, stop it
    stop

    # Create the new tmux session & start the server
    echo "About to start server using the following command:"
    echo "$> ${SERVER_DIR}/rocketstation_DedicatedServer.x86_64 ${SERVER_START_PARAMS}"
    tmux new-session -d -s "${TMUX_SESSION}"
    echo "tmux session ${TMUX_SESSION} started"
    tmux send -t "${TMUX_SESSION}" "${SERVER_DIR}/rocketstation_DedicatedServer.x86_64 ${SERVER_START_PARAMS}" ENTER
    echo "Server startup command sent"
}

console() {
    if tmux has-session -t "${TMUX_SESSION}" > /dev/null 2>&1; then
        echo "To exit the console you must press CTRL-B then D. If you just kill the session it will kill the server. Do you understand? (y/N)"
        read -s -n 1 key
        case $key in
            y|Y)
            tmux attach-session -t "${TMUX_SESSION}"
        esac
    else
        echo "No tmux session found - use 'start' instead."
        exit 1
    fi
}

stop() {
    echo "Stop command issued"
    if tmux has-session -t "${TMUX_SESSION}" > /dev/null 2>&1; then
        echo "tmux session exists, attempting graceful server shutdown"
        tmux send -t "${TMUX_SESSION}" save "${SAVE_NAME}" ENTER
        echo "game save command sent"
        sleep 5
        tmux send -t "${TMUX_SESSION}" quit ENTER
        exho "quit command sent"
        sleep 10
        if tmux has-session -t "${TMUX_SESSION}" > /dev/null 2>&1; then
            echo "tmux session still exists after 10 seconds - killing"
            tmux kill-session -t "${TMUX_SESSION}"
        fi
    fi
}

kill() {
    if tmux has-session -t "${TMUX_SESSION}" > /dev/null 2>&1; then
        echo "tmux session exists - killing"
        tmux kill-session -t "${TMUX_SESSION}"
    fi
}

case "$1" in
    install) install ;;
    start) start ;;
    restart) start ;;
    stop) stop ;;
    update) install ;;
    console) console ;;
    kill) kill ;;
    *)
        echo "Usage: $0 {install|start|stop|restart|update|console}"
        exit 1
esac

exit 0