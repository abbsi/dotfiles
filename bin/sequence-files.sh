#!/bin/bash
# Script to rename files into a numerical sequence and keep the original extension

a=1
for i in *; do
  filename=$(basename -- "$i")
  extension="${filename##*.}"
  # filename="${filename%.*}"
  new=$(printf "%04d.$extension" "$a") #04 pad to length of 4
  git mv "$i" "$new"
  let a=a+1
done
