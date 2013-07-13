#!/bin/sh
# VM setup/update bootstrap script.

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Enable password-less sudo for the current user.
sudo sh -c "echo '$USER ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USER"

if [ "$USER" != "netchat" ] ; then
  # If this is not as netchat, create up the netchat user.

  if [ -f /etc/netchat/prod.keys ] ; then
    # netchat's password is random in production.
    PASSWORD="$(openssl rand -hex 32)"
  fi
  if [ ! -f /etc/netchat/prod.keys ] ; then
    # netchat's password is always "netchat" in development VMs.
    PASSWORD="netchat"
  fi

  if [ ! -d /home/netchat ] ; then
    sudo useradd --home-dir /home/netchat --create-home \
        --user-group --groups sudo --shell $SHELL \
        --password $(echo "$PASSWORD" | openssl passwd -1 -stdin) netchat
  fi

  # Set up password-less sudo for the netchat user.
  sudo sh -c "echo 'netchat ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/netchat"

  # Set up SSH public key access.
  sudo mkdir -p /home/netchat/.ssh
  sudo chown netchat:netchat /home/netchat/.ssh
  sudo chmod 0700 /home/netchat/.ssh
  if [ -f ~/.ssh/authorized_keys ] ; then
    sudo cp ~/.ssh/authorized_keys /home/netchat/.ssh/authorized_keys
    sudo chown netchat:netchat /home/netchat/.ssh/authorized_keys
    sudo chmod 0600 /home/netchat/.ssh/authorized_keys
  fi
fi

# If the server VM repo is already checked out, run the update script in there.
if [ "$USER" = "netchat" ] ; then
  if [ -f /home/netchat/vm/script/update.sh ] ; then
    cd /home/netchat/vm
    git checkout master
    git pull --ff-only public master
    exec /home/netchat/vm/script/update.sh
  fi
fi

# Download and run the update script.
curl -fLsS https://github.com/pwnall/netchat-server-vm/raw/master/script/update.sh | \
    sudo -u netchat -i
