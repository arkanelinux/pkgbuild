#!/bin/bash

export repo="$USER@192.168.188.4:/var/luna/git/traefik/assets/arkanerepo-repo/arkane/os/x86_64/"

scp ./arkane.* $repo
scp ./*/*.pkg.tar.zst $repo
