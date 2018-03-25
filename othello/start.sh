#!/bin/bash

export PORT=5400

cd ~/www/othello
./bin/othello stop || true
./bin/othello start
