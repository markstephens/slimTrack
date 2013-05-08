slimTrack
=========

A proof of concept to see if we can move a lot of tracking code server-side. For the following reasons:
- Vastly reduced code size on the frontend
- Less processing work to be done by the browser
- Simpler interface, with fewer functions available.
- Smaller traffic size between client and server for each tracking call
- Re-use across all channels, Desktop, webapp, epaper, flipboard, future product x
- Unified interface means we're quicker to react and make changes.
- Data can be sent to multiple datamarts; iJento, GA, Splunk etc.

Requirements
------------
- Ruby (Preferably 2.0.0 or latest 1.9)
- Bundler (<code>gem install bundler</code>)
- Redis (http://redis.io/download)
- MongoDB (http://www.mongodb.org/downloads)

Installation locally
--------------------
- Clone repo
- <code>[sudo] bundle install</code>

Running locally
---------------
In three separate shells
- <code>$ rake redis</code> (unless it's running as a service)
- <code>$ rake mongo</code> (unless it's running as a service)
- <code>$ rake server</code> (to start the frontent server) - goto <a href="http://localhost:5000">http://localhost:5000</a>
- <code>$ rake runner</code> (to process the tags)

Build tools and tasks
---------------------
<pre>
$ rake -T
rake build     # Buld a version of JavaScript
rake console   # Start a console with slimTrack preloaded.
rake deploy    # Deploy JavaScript (to Maven?)
rake mongo     # Start mongo storage.
rake redis     # Start redis storage.
rake runner    # Start the runner, and process tags.
rake server    # Start the webserver.
rake versions  # Show versions and profiles available for build.
</pre>
