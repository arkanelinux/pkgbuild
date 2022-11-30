#!/bin/bash

export repo="${USER}@${ARKANE_REPO}"

scp ./arkane.* $repo
scp ./*/*.pkg.tar.zst $repo
scp ./*/*.pkg.tar.zst.sig $repo
