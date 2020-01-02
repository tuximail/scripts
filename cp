#!/bin/bash

##############################################################
#
# This script calls cp directly with all parameters called
# except param -B which does not exist in cp.
# This param indicates that you want a progressbar displayed
#
# WORK FOR THIS SCRIPT IS STILL IN PROGRESS!
############################################################
args=""

# we trap interruptions so the actual cp process kan get killed, too.
# however we cannot trap SIGKILL so this script gets terminated by kill -9 the cp subprocess will remain
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

for var in $@; do
  [[ "$var" != "-B" ]] && args="$args $var"
done

args=$(echo "$args" | sed 's/\ //')

if [[ "$args" == "$@" ]]; then
  cp $args
  exit $?
fi

cp $args &

function prog() {
    local w=80 p=$1;  shift
    # create a string of spaces, then change them to dots
    printf -v dots "%*s" "$(( $p*$w/100 ))" ""; dots=${dots// /.};
    # print those dots on a fixed-width space plus the percentage etc.
    printf "\r\e[K|%-*s| %3d %% %s" "$w" "$dots" "$p" "$*";
}

function test() {
for x in {1..100} ; do
    prog "$x" still working...
    sleep .1   # do some work here
done ; echo
}


pid=$(ps ax | grep -iw "cp" | grep -v grep | cut -dp -f1 | sed s'/\ //g' | sed -n '$p')
#if we cannot get the pid, cp must have crashed and printed to stderr. So user already know what's happening
[[ "$pid" == "" ]] && exit 2
name=$(ps ax | grep $pid | grep -v grep | cut -d\: -f2 | sed 's/...//')
src=$(echo "$name" | awk '{print $(NF-1)}')
src_size=$(du -b "$src" | tail -n1 | awk '{print $(NF-1)}')
[[ "$src_size" == "" ]] && echo "FATAL! Could not get size of source folder!" && exit 2
one_percent=$(($src_size/100))
#echo $src_size

#echo $pid


while [[ -d "/proc/$pid/" ]]; do

  dest_size=$(cat /proc/$pid/io | grep -w write_bytes | cut -d\  -f2)
  [[ "$dest_size" == "" ]] && echo "FATAL! Could not get size of dest folder!" && exit 2
  prog $(($dest_size/one_percent)) $name
  sleep 1s

done
echo