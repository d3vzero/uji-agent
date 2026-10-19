#!/bin/bash

if [ -z "$1" ]; then
    echo "Penggunaan: $0 <nama_file>" >&2
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: File '$1' tidak ditemukan." >&2
    exit 1
fi

baris=0
kata=0
karakter=$(stat -c %s "$1")

while IFS= read -r line || [ -n "$line" ]; do
    baris=$((baris + 1))
    read -ra kata_kata <<< "$line"
    kata=$((kata + ${#kata_kata[@]}))
done < "$1"

echo "Baris: $baris"
echo "Kata: $kata"
echo "Byte: $karakter"
