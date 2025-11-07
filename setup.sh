#!/bin/bash

function vl () {
  ruby lib/vl.rb $*
}

function vl_samples () {
  echo "====== vl sample1.vl ======"
  vl samples/sample1.vl
  echo "====== vl sample2.vl ======"
  vl samples/sample2.vl
  echo "====== vl sample3.vl ======"
  vl samples/sample3.vl
  echo "====== vl sample4.vl ======"
  vl samples/sample4.vl
  echo "====== vl sample5.vl 2 2 ======"
  vl samples/sample5.vl 2 2
  echo "====== vl sample6.vl ./sample5.vl ======"
  vl samples/sample6.vl ./sample5.vl
}

function vl_test () {
  test_dir=test
  if [ "$1" = "answer" ]; then
    test_dir=test_answer
  fi

  if [ "$1" = "1" ] || [ "$1" = "" ]; then
    _vl_test_subject $test_dir/test1/main.vl "'Matcher株式会社' を出力しなさい"
    _vl_test_case $test_dir/test1/main.vl "" "Matcher株式会社"
    echo ""
  fi

  if [ "$1" = "2" ] || [ "$1" = "" ]; then
    _vl_test_subject $test_dir/test2/main.vl "入力の2乗を出力しなさい"
    _vl_test_case $test_dir/test2/main.vl "3" "9"
    _vl_test_case $test_dir/test2/main.vl "0" "0"
    _vl_test_case $test_dir/test2/main.vl "-2" "4"
    echo ""
  fi

  if [ "$1" = "3" ] || [ "$1" = "" ]; then
    _vl_test_subject $test_dir/test3/main.vl "入力の名前を使って'私の名前は<name>です'を出力しなさい"
    _vl_test_case $test_dir/test3/main.vl "山田太郎" "私の名前は山田太郎です"
    _vl_test_case $test_dir/test3/main.vl "抹茶花子" "私の名前は抹茶花子です"
    echo ""
  fi

  if [ "$1" = "4" ] || [ "$1" = "" ]; then
    _vl_test_subject $test_dir/test4/main.vl "入力が'りんご'の場合は'apple'、'ばなな'の場合は'banana'、それ以外の場合は'fruit'を出力しなさい"
    _vl_test_case $test_dir/test4/main.vl "りんご" "apple"
    _vl_test_case $test_dir/test4/main.vl "ばなな" "banana"
    _vl_test_case $test_dir/test4/main.vl "ぶどう" "fruit"
    _vl_test_case $test_dir/test4/main.vl "れもん" "fruit"
    echo ""
  fi

  if [ "$1" = "5" ] || [ "$1" = "" ]; then
    _vl_test_subject $test_dir/test5/main.vl "入力の階乗を出力しなさい"
    _vl_test_case $test_dir/test5/main.vl "0" "1"
    _vl_test_case $test_dir/test5/main.vl "1" "1"
    _vl_test_case $test_dir/test5/main.vl "4" "24"
    echo ""
  fi
}

function _vl_test_subject () {
  file_path=$1
  subject=$2
  echo "====== $file_path ======"
  echo "-- subject"
  echo $subject
}

function _vl_test_case () {
  file_path=$1
  args=$2
  expect=$3
  res=$(vl $file_path $args)
  if [ "$expect" = "$res" ]; then
    color=32
  else
    color=31
  fi
  echo -e "\e[${color}m-- case
vl $file_path $args
-- expect
$expect
-- result
$res
\e[m"
}
