#!/bin/bash

d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT

PASS=0
FAIL=0
TOTAL=0

test_case() {
    local desc="$1"
    local file="$2"

    TOTAL=$((TOTAL + 1))

    local expected_lines=$(awk 'END{print NR}' "$file")
    local expected_words=$(wc -w < "$file")
    local expected_bytes=$(wc -c < "$file")

    local output=$(bash hitung.sh "$file" 2>&1)
    local actual_lines=$(echo "$output" | grep "Baris:" | awk '{print $2}')
    local actual_words=$(echo "$output" | grep "Kata:" | awk '{print $2}')
    local actual_bytes=$(echo "$output" | grep "Byte:" | awk '{print $2}')

    if [ "$actual_lines" != "$expected_lines" ] || [ "$actual_words" != "$expected_words" ] || [ "$actual_bytes" != "$expected_bytes" ]; then
        FAIL=$((FAIL + 1))
        echo "FAIL: $desc"
        echo "  Expected -> Baris: $expected_lines, Kata: $expected_words, Byte: $expected_bytes"
        echo "  Actual   -> Baris: $actual_lines, Kata: $actual_words, Byte: $actual_bytes"
    else
        PASS=$((PASS + 1))
        echo "PASS: $desc"
    fi
}

# Test 1: File kosong
> "$d/empty.txt"
test_case "File kosong" "$d/empty.txt"

# Test 2: Satu baris tanpa newline
echo -n "hello" > "$d/one_line.txt"
test_case "Satu baris tanpa newline" "$d/one_line.txt"

# Test 3: Satu baris dengan newline
echo "hello" > "$d/one_line_nl.txt"
test_case "Satu baris dengan newline" "$d/one_line_nl.txt"

# Test 4: Multiple baris dan kata
printf "hello world\nfoo bar baz\n" > "$d/multi.txt"
test_case "Multiple baris dan kata" "$d/multi.txt"

# Test 5: Baris kosong di tengah
printf "line1\n\nline3\n" > "$d/empty_line.txt"
test_case "Baris kosong di tengah" "$d/empty_line.txt"

# Test 6: Spasi berlebih
printf "  hello   world  \n" > "$d/spaces.txt"
test_case "Spasi berlebih" "$d/spaces.txt"

# Test 7: Baris berisi karakter glob (* ?)
printf "file*\n?test\na*b ?c\n" > "$d/glob_chars.txt"
test_case "Karakter glob (* ?) di baris" "$d/glob_chars.txt"

# Test 8: Baris hanya spasi dan karakter glob
printf "  * ?  \n" > "$d/glob_only.txt"
test_case "Baris hanya spasi dan karakter glob" "$d/glob_only.txt"

# Test 9: Tanpa argumen
TOTAL=$((TOTAL + 1))
stdout_noarg=$(bash hitung.sh 2>/dev/null)
stderr_noarg=$(bash hitung.sh 2>&1 >/dev/null)
code_noarg=$?
if [ "$code_noarg" != "0" ] && [ -z "$stdout_noarg" ] && [ -n "$stderr_noarg" ]; then
    PASS=$((PASS + 1))
    echo "PASS: Tanpa argumen"
else
    FAIL=$((FAIL + 1))
    echo "FAIL: Tanpa argumen"
fi

# Test 10: File tidak ada
TOTAL=$((TOTAL + 1))
stdout_missing=$(bash hitung.sh "/nonexistent/file.txt" 2>/dev/null)
stderr_missing=$(bash hitung.sh "/nonexistent/file.txt" 2>&1 >/dev/null)
code_missing=$?
if [ "$code_missing" != "0" ] && [ -z "$stdout_missing" ] && [ -n "$stderr_missing" ]; then
    PASS=$((PASS + 1))
    echo "PASS: File tidak ada"
else
    FAIL=$((FAIL + 1))
    echo "FAIL: File tidak ada"
fi

# Test 11: Opsi -h
TOTAL=$((TOTAL + 1))
stdout_h=$(bash hitung.sh -h 2>/dev/null)
code_h=$?
if [ "$code_h" = "0" ] && [ -n "$stdout_h" ]; then
    PASS=$((PASS + 1))
    echo "PASS: Opsi -h"
else
    FAIL=$((FAIL + 1))
    echo "FAIL: Opsi -h"
fi

# Test 12: Opsi --help
TOTAL=$((TOTAL + 1))
stdout_help=$(bash hitung.sh --help 2>/dev/null)
code_help=$?
if [ "$code_help" = "0" ] && [ -n "$stdout_help" ]; then
    PASS=$((PASS + 1))
    echo "PASS: Opsi --help"
else
    FAIL=$((FAIL + 1))
    echo "FAIL: Opsi --help"
fi

echo ""
echo "Hasil: $PASS/$TOTAL passed, $FAIL failed"

if [ "$FAIL" -eq 0 ]; then
    echo "Semua tes berhasil! ✅"
    exit 0
else
    echo "Ada tes yang gagal! ❌"
    exit 1
fi
