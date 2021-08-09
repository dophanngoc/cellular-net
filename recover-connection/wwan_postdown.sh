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
      if (ip link set "$i_face" down >/dev/null 2>&1); then
         if [ -c "$dev_file" ]; then
            if (echo -e 'AT$QCRMCALL=0,1\r' > $dev_file); then
               echo "[+] $i_face at $dev_file is disconnected"
               exit 0
            else
               echo "[!] unable to communicate with $dev_file"
               exit 1
            fi
         else
            echo "[!] $dev_file not found"
            exit 1
         fi
      else
         echo "[!] Could not bring down $i_face."
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
