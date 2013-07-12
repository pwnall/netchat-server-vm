#!/bin/sh
# Idempotent web server VM setup steps.

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Git URL that allows un-authenticated pulls.
GIT_PUBLIC_URL=git://github.com/netchat/netchat-game-server.git

# Git URL that allows pushes, but requires authentication.
GIT_PUSH_URL=git@github.com:netchat/netchat-game-server.git

# If the game server repository is already checked out, update the code.
if [ -d ~/game ] ; then
  cd ~/game
  git checkout master
  git pull --ff-only "$GIT_PUBLIC_URL" master
  bundle install
  rake db:migrate db:seed
fi

# Otherwise, check out the web server repository.
if [ ! -d ~/netchat/web ] ; then
  cd ~
  git clone "$GIT_PUBLIC_URL" game
  cd ~/web
  bundle install
  rake db:create db:migrate db:seed

  # Switch the repository URL to the one that accepts pushes.
  git remote rename origin public
  git remote add origin "$GIT_PUSH_URL"
fi

# Setup the web server daemon.
cd ~/web
if [ -f /etc/netchat/prod.keys ] ; then
  rake assets:precompile
  sudo foreman export upstart /etc/init --app=netchat-web \
    --procfile=Procfile.prod --env=config/production.env --user=$USER \
    --port=9000
fi
if [ ! -f /etc/netchat/prod.keys ] ; then
  sudo foreman export upstart /etc/init --app=netchat-game --procfile=Procfile \
    --env=.env --user=$USER --port=9000
fi
# 'stop' will fail during the initial setup, so ignore its exit status.
sudo stop netchat-web || echo 'Ignore the error above during initial setup'
sudo start netchat-web
