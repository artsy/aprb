#!/usr/bin/env bash

set -e

sudo pip install docker-compose==1.9.0
sudo apt-get install python-dev
sudo pip install git+http://github.com/artsy/hokusai.git@master#egg=Hokusai
