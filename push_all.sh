#!/bin/bash

export repo='dennis@192.168.188.4:/var/luna/git/traefik/assets/arkanerepo-repo/'

scp ./arkane.* $repo
scp ./*/*.pkg.tar.zst $repo
