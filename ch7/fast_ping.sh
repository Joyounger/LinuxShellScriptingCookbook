#!/bin/bash
#Filename: fast_ping.sh
# Change base address 192.168.0 according to your network.

# 将命令块放入(),使其中的命令作为子shell.&使之脱离当前线程

for ip in 192.168.0.{1..255} ;
do
   (
      ping $ip -c2 &> /dev/null ;
  
      if [ $? -eq 0 ];
      then
       echo $ip is alive
      fi
   )&
  done
wait