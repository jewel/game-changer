Turbo Encabulator
=====

This launches video games and manages saved games from a central server.  I
wrote it because when the children have friends over there are more children
than computers.  By centralizing saved games, the children can happily play from
whichever workstation is available.

This works well for small computer labs; it could also be used share one
computer between multiple children.

Features
----

* Only the server needs to have enough disk space to store all games, the
  children's computers only need enough space to install one game at a time.

* Older children can be admins so that they can add new users and games

Future Features
-----

* Track the time spent per child

* Reward children with extra time via the interface

* Restrict titles based on age

* Auto-update client from the server

* Native supports for browser-based games (via chromium's --app mode)

Requirements
----

* Server is a Ruby on Rails app.

* Client is a Ruby GTK app.  It is only tested on Linux, but could work on
  Windows; it does not rely on any special Linux features.

Server installation
-----

The server is a standard rails app.  To run under docker:

```
mkdir /var/local/game-changer
chown 1000.1000 /var/local/game-changer
docker build -t game-changer .
echo SECRET_KEY_BASE=supersecretrandom > .env
docker run --env-file=.env -d --restart unless-stopped \
  -p 4004:3000 \
  --mount type=bind,source=/var/local/game-changer,target=/rails/storage \
  game-changer
```

Without docker:

```
bundle install
RAILS_ENV=production bin/rails db:migrate
RAILS_ENV=production bin/rails server --bind 0 --port 4004
```

The games will be stored in the "storage" directory.  The saved games will be
stored in there too.  By default, a sqlite database will also be in that
directory.

Navigate to http://server:4004/admin and add some users and games.

Games are best uploaded as a tar file, as that will preserve the executable bit.


Client installation
-----

The server manages client installations and upgrades.

To do the first install, run the following on each kid computer.  Currently this
is only tested on Ubuntu 22.04.

```bash
curl -s http://server-url/install | sudo bash
```

This will:

* Install the client, including a .desktop file so it can be run by other users

* Put the server URL in `/etc/game-changer-server`

* Set up a new user named "turbo".  The default password is "encabulator", but
  this can be changed on the server.

* Set up a graphical shell which contains nothing but the client, i.e. a kiosk mode.

* Add a script to boot that will run the install script again, to
handle further client upgrades.
