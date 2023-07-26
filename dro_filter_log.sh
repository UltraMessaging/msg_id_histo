#!/bin/sh
# dro_filter_log.sh - tool to omit "normal" log lines from a DRO log file.
#   The implication is that lines that are printed deserve attention.
#   See https://github.com/UltraMessaging/msg_id_histo for full doc.
#
# This code and its documentation is Copyright 2011-2021 Informatica
# and licensed "public domain" style under Creative Commons "CC0":
#   http://creativecommons.org/publicdomain/zero/1.0/
# To the extent possible under law, the contributors to this project have
# waived all copyright and related or neighboring rights to this work.
# In other words, you can use this code for any purpose without any
# restrictions.  This work is published from: United States.  The project home
# is https://github.com/UltraMessaging/msg_id_histo

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
