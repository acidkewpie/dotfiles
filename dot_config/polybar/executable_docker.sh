#!/bin/sh

running=$(sudo -S docker ps -qf status=running | wc -l)
exited=$(sudo docker ps -qf status=exited | wc -l)
dead=$(sudo docker ps -qf status=dead | wc -l)

echo $running/$exited/$dead


