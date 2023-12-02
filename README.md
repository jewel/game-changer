Turbo Encabulator
=====

This launches video games and manages saved games from a central server.  I
wrote it because when the children have friends over there are more children
than computers.  By centralizing saved games, the children can happily play
from whichever workstation is available.

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

* Client is a Ruby GTK app.  It is only tested on Linux, but could work on Windows; it does not rely on any special Linux features.

Installation
-----

See instructions for the [client](client/README.md) and [server](server/README.md)
