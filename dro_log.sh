#!/bin/sh
# dro_log.sh

sed -e '
  /^$/d
  /Gwd-6033-391:/d
  /Gwd-7122-1:/d
  /Gwd-7136-1:/d
  /Gwd-7136-2:/d
  /Gwd-7097-1:/d
  /Core-6259-2:/d
  /Gwd-6361-74:/d
  /Gwd-6033-618: peer portal .* received connection from /d
  /Gwd-6033-618: peer portal .* connected to /d
' "$@" 
