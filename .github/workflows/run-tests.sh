#!/bin/sh
# Created by Jack Wilson on 01/20/2021

output="$(vendor/bin/hacktest tests/)";
if $?
then
  echo "success";
  exit 0;
else
  echo "failure";
  echo $output;
  exit 1;
fi
