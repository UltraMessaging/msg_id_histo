#!/bin/sh
# dro_filter_log.sh - tool to omit "normal" log lines from a DRO log file.
#   The implication is that lines that are printed deserve attention.
#   See https://github.com/UltraMessaging/msg_id_histo for full doc.

# This work is dedicated to the public domain under CC0 1.0 Universal:
# http://creativecommons.org/publicdomain/zero/1.0/
# 
# To the extent possible under law, Steven Ford has waived all copyright
# and related or neighboring rights to this work. In other words, you can 
# use this code for any purpose without any restrictions.
# This work is published from: United States.
# Project home: https://github.com/fordsfords/msg_id_histo

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
