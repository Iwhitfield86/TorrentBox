TorrentBox
==========

Introduction
------------
This project's goal is to add support for handling BitTorrent metadata files to iOS devices.  By registering support for .torrent files TorrentBox will be given access to such files when accessed in other apps, such as Safari.

iOS devices do not have the necessary resources for performing BitTorrent file transfers locally.  However, by pushing the .torrent files to another host the metadata can be used later to begin BitTorrent transfers on another host.

Using the [Dropbox API](http://www.dropbox.com) it is possible to do just this, so that BitTorrent transfers can be intiated manually later. In an advanced configurations, users may find it useful to have their BitTorrent clients watch their Dropbox directory and automatically begin transfers when new files are added.

Scope
-----
This project is simply a way to get files from point A to point B. No actual BitTorrent transfers are performed by this app, and this is in no way encouraging bootlegging (piracy).  Also, this project does not encourage the saving of files from BitTorrent transfers in your Dropbox directory as it would likely induce unnecessary network traffic.

License
-------
TBD

Contact
-------
[Brian Partridge](http://github.com/brianpartridge)

