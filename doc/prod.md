# Production Deployment Instructions

The VM setup scripts can be used to deploy a forked game server into
production.


## Production Keys

Production deployments should not use the NetChat development SSL keys or API
keys. Read the
[keys repository docs](https://github.com/netchat/netchat-dev-keys/blob/master/README.md)
and set up your own keys repository.

The git URL to the keys repository should be saved in `/etc/netchat/prod.keys`
on your production server. The existence of this file tells the VM scripts to
configure a production server.

```bash
sudo mkdir /etc/netchat
sudo sh -c 'echo "https://you@github.com/you/private-keys-repo.git" > /etc/netchat/prod.keys
```

## Game Server Setup

Create the file `/etc/netchat/game` to tell the VM scripts to set up a game
server in production mode.

```bash
sudo touch /etc/netchat/game
```

Kick off the VM setup script. After one sudo prompt, the script will run on its
own for a while. If the keys repository requires a password, you will be
prompted for it a few minutes into the setup.

```bash
curl -fLsS https://github.com/netchat/netchat-server-vm/raw/master/script/setup.sh | sh
```

