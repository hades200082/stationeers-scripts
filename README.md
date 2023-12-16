# Stationeers dedicated server script

The purpose of this script is to help server admins create & manage a Stationeers dedicated server.

It runs the server in a tmux window to leave your console free for other commands.

## Get the script

Run the following command to get the script on your linux server.

```bash
wget -O stationeers.sh https://raw.githubusercontent.com/hades200082/stationeers-scripts/main/stationeers.sh && chmod +x stationeers.sh
```

## Edit the settings

At the top of the script are a number of settings that you can customise to suite your needs.

## Usage

Once you've customised the settings, install the dedicated server:

```bash
./stationeers.sh install
```

OR just ask it to start the server:

```bash
./stationeers.sh start
```

In either case, if SteamCMD is not in the expected location it will be installed. Then, if the dedicated server is not in the expected location it will also be installed.

### Start or restart the server

```bash
./stationeers.sh start
```

or

```bash
./stationeers.sh restart
```

These commands both do the same thing.

### Stop the server

```bash
./stationeers.sh stop
```

This will attempt to save the world and stop the server gracefully. If it takes too long (>10 secs) it will just kill it.

### Kill the server

```bash
./stationeers.sh kill
```

This will just kill the server. No save. No graceful shutdown.

### Update the server

```bash
./stationeers.sh update
```

Updates the server files from SteamCMD and then restarts the server instance.

### View the server console

```bash
./stationeers.sh console
```

This will attach the tmux window allowing you to see and interact with the server session directly.

To exit the console you **must** use CTRL-B, D. If you close the session any other way it will kill the server.