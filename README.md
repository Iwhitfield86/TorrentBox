TorrentBox
==========

Introduction
------------
This project's goal is to add support for handling BitTorrent metadata files to iOS devices.  By registering support for .torrent files TorrentBox will be given access to such files when accessed in other apps, such as Safari.

iOS devices do not have the necessary resources for performing BitTorrent file transfers locally.  However, by pushing the .torrent files to another host the metadata can be used later to begin BitTorrent transfers on another host.

Using the [Dropbox API](http://www.dropbox.com) it is possible to do just this, so that BitTorrent transfers can be intiated manually later. In an advanced configurations, users may find it useful to have their BitTorrent clients watch their Dropbox directory and automatically begin transfers when new files are added.

Development is currently in progress for the iPad on iOS 3.2, with iPhone support on iOS 4 on deck.  TorrentBox will be made available for free on the App Store soon.

Scope
-----
This project is simply a way to get files from point A to point B. No actual BitTorrent transfers are performed by this app, and this is in no way encouraging bootlegging (piracy).  Also, this project does not encourage the saving of files from BitTorrent transfers in your Dropbox directory as it would likely induce unnecessary network traffic.

License
-------
MIT, see LICENSE file for details.

Support
-------
For those interested, a Pledgie link is available at the top of the page to allow donations to the projects.  Thanks for the support!

That isn't all we need though.  I can handle the code, but TorrentBox needs some niceties.  If you can help with the design of a great icon or help create some great sound effects, it would really help put a nice shine or the app.

And if you can't donate or help with the niceties you can still spread the word.  Don't keep it to yourself though, tell friends about TorrentBox.  This is BitTorrent after all, the more peers the better.

Contact
-------
[Brian Partridge](http://github.com/brianpartridge)

