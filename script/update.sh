#!/bin/sh
# Idempotent server VM update script.

# Git URL that allows un-authenticated pulls.
GIT_PUBLIC_URL=https://git.pwnb.us/netchat/netchat-server-vm.git

# Git URL that allows pushes, but requires authentication.
GIT_PUSH_URL=git@git.pwnb.us:netchat/netchat-server-vm.git

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Make sure we're running as the netchat user.
if [ "$USER" != "netchat" ] ; then
  echo "This script must be run as the netchat user"
  exit 1
fi
if [ "$HOME" != "/home/netchat" ] ; then
  echo "This script must be run with \$HOME set to /home/netchat"
  exit 1
fi

# Enable password-less sudo for the current user.
sudo sh -c "echo '$USER ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/$USER"

# Update all system packages.
sudo apt-get update -qq
sudo apt-get -y dist-upgrade

# debconf-get-selections is useful for figuring out debconf defaults.
sudo apt-get install -y debconf-utils

# Quiet all package installation prompts.
sudo debconf-set-selections <<'END'
debconf debconf/frontend select Noninteractive
debconf debconf/priority select critical
END

# Git.
sudo apt-get install -y git


# If the server VM scripts repository is already checked out, update the code.
if [ -d ~/vm ] ; then
  cd ~/vm
  git checkout master
  git pull "$GIT_PUBLIC_URL" master
fi

# Otherwise, check out the VM scripts server repository.
if [ ! -d ~/vm ] ; then
  cd ~
  git clone "$GIT_PUBLIC_URL" vm
  cd ~/vm

  # Switch the repository URL to the one that accepts pushes.
  git remote rename origin public
  git remote add origin "$GIT_PUSH_URL"
fi

# Run the individual update scripts.
cd ~/vm
script/update-keys.sh
if [ -f /etc/netchat/prod.keys ] ; then
  # Production VMs
  if [ -f /etc/netchat/web ] ; then
    script/update-web-deps.sh
    script/update-web.sh
  fi
fi
if [ ! -f /etc/netchat/prod.keys ] ; then
  # Development VMs run all the servers in the same VM.
  script/update-web-deps.sh
  script/update-web.sh
fi

# Land in the user's home directory.
cd ~
