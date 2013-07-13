#!/bin/sh
# Idempotent Web server VM dependencies setup steps.

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Build environment for gems with native extensions.
sudo apt-get install -y build-essential

# The rice gem uses automake.
sudo apt-get install -y automake

# Easy way to add PPAs.
sudo apt-get install -y software-properties-common

# Git.
sudo apt-get install -y git

# nginx.
sudo apt-get install -y nginx

# nginx configuration for the web server.
if [ -f /etc/netchat/prod.keys ] ; then
  sudo cp ~/vm/nginx/prod/netchat-web.conf /etc/nginx/sites-available
fi
if [ ! -f /etc/netchat/prod.keys ] ; then
  sudo cp ~/vm/nginx/netchat-web.conf /etc/nginx/sites-available
fi
sudo chown root:root /etc/nginx/sites-available/netchat-game.conf
sudo ln -s -f /etc/nginx/sites-available/netchat-game.conf \
              /etc/nginx/sites-enabled/netchat-game.conf
sudo rm -f /etc/nginx/sites-enabled/default

# Load the new configuration into nginx.
sudo /etc/init.d/nginx reload

# Postgres.
sudo apt-get install -y libpq-dev postgresql postgresql-client \
    postgresql-contrib postgresql-server-dev-all
if sudo -u postgres createuser --superuser $USER; then
  # Don't attempt to re-create the user's database if the user already exists.
  createdb $USER
fi

# Configure postgres to use ident authentication over TCP.
sudo ruby <<"EOF"
pg_file = Dir['/etc/postgresql/**/pg_hba.conf'].first
lines = File.read(pg_file).split("\n")
lines.each do |line|
  next unless /^host.*127\.0\.0\.1.*md5$/ =~ line
  line.gsub! 'md5', 'ident'
end
File.open(pg_file, 'w') { |f| f.write lines.join("\n") }
EOF
sudo /etc/init.d/postgresql restart

# Ident server used by the node.js postgres connection.
sudo apt-get install -y oidentd

# node.js
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update -qq
sudo apt-get install -y nodejs

# CoffeeScript provides cake, which runs the Cakefile in the metrics server.
npm cache add coffee-script
sudo npm install -g coffee-script

# SQLite, because Rails is uncomfortable without it.
sudo apt-get install -y libsqlite3-dev sqlite3

# Ruby and Rubygems, used by the game server, which is written in Rails.
sudo apt-get install -y ruby ruby-dev
sudo env REALLY_GEM_UPDATE_SYSTEM=1 gem update --system 1.8.25

# Bundler, used to install all the gems in a Gemfile.
sudo gem install bundler

# Foreman sets up a system service to run the server as a daemon.
sudo gem install foreman

# Rake runs the commands in the server's Rakefile.
sudo gem install rake

# libv8, used by the therubyracer, chokes when installed by bundler.
sudo gem install therubyracer


