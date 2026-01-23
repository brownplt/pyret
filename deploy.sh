#!/bin/bash

SHORT_COMMIT=`echo $TRAVIS_COMMIT | cut -c1-7`
VERSION=$SHORT_COMMIT
npm install
make pages

tar czf site.tgz site/*

# NOTE(joe):
#
# The "*" in front of dele makes the copy continue if the command fails.  This
# makes it so new branches don't need to have someone manually make a file to
# delete (see the -Q option in `man curl`).

curl -u $FTP_USER:$FTP_PASS \
     -Q "*dele pyret.org/site-copied.tgz" \
     -Q "-rnfr site-copied.tgz" \
     -Q "-rnto site.tgz" \
     --ftp-create-dirs \
     -T site.tgz ftp://ftp.cs.brown.edu/pyret.org/site-copied.tgz

