#!/bin/bash

mv errBounds.cfg errBounds.cfg.bk2
git pull
mv errBounds.cfg.bk2 errBounds.cfg
./z-checker-pull-reset.sh
