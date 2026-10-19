#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Penggunaan: $0 [-j] <nama_file>"
    exit 0
fi

json=0
if [ "$1" = "-j" ]; then json=1; shift; fi

if [ -z "$1" ]; then
    echo "Penggunaan: $0 [-j] <nama_file>" >&2
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File '$1' tidak ditemukan." >&2
    exit 1
fi

baris=0
kata=0
byte=$(stat -c %s "$1")

while IFS= read -r line || [ -n "$line" ]; do
    baris=$((baris + 1))
    read -ra kata_kata <<< "$line"
    kata=$((kata + ${#kata_kata[@]}))
done < "$1"

if [ "$json" = "1" ]; then
    printf '{"baris":%d,"kata":%d,"byte":%d}\n' "$baris" "$kata" "$byte"
else
    echo "Baris: $baris"
    echo "Kata: $kata"
    echo "Byte: $byte"
fi
