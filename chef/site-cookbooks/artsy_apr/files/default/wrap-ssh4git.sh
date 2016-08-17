#!/usr/bin/env bash
/usr/bin/env ssh -o "StrictHostKeyChecking=no" -i "/home/deploy/.ssh/deploy_key" $1 $2
