#!/bin/bash

set -e

module_lte="simcom_wwan"
i_face="wwan0"
dev_file="/dev/ttyUSB2"
if [ $UID != 0 ]; then
   echo please execute as root!
   exit 1
fi
if (modinfo "$module_lte" >/dev/null 2>&1); then
   if (ip link show dev "$i_face" >/dev/null 2>&1); then
      if (ip link set "$i_face" up >/dev/null 2>&1); then
         if [ -c "$dev_file" ]; then
            if (echo -e 'AT+CNMP=2\r' > $dev_file); then
               sleep 2
               if (echo -e 'AT$QCRMCALL=1,1\r' > $dev_file); then
                  sleep 4
                  echo "[+] $i_face at $dev_file is ready for an IP Address"
                  exit 0
               else
                  echo "[!] Failed to activate 4G connection on $dev_file"
                  exit 1
               fi
            else
               echo "[!] unable to communicate with $dev_file"
               ifconfig "$i_face" down
               exit 1
            fi
         else
            echo "[!] $dev_file not found"
            ifconfig "$i_face" down
            exit 1
         fi
      else
         echo "[!] Could not bring up $i_face."
         exit 1
      fi
   else
      echo "[!] interface $i_face not found"
      exit 1
   fi
else
   echo "[!] $module_lte module not found"
   exit 1
fi
