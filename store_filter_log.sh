#!/bin/sh
# store_filter_log.sh - tool to omit "normal" log lines from a Store log file.
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
  /Store-8955-4: Initial UMP log rollover/d
  /Core-7911-1: Onload extensions API/d
  /Store-5688-5273: Latency Busters/d
  /Store-5688-5274: UMP/d
  /Store-10761-01: (C)/d
  /^	This software/d
  /^	A current list/d
  /Store-5688-5268: Linux/d
  /Store-10664-1: Initial CPU/d
  /Store-10664-3: Initial CPU/d
  /Store-10664-6: Updated CPU/d
  /Store-10366-1: Created daemon mon/d
  /Core-10403-151: Reactor Only/d
  /Store-8079-10: Starting store/d
  /Core-10403-150: Context (/d
  /Store-8079-1: Created context thread/d
  /Store-10664-8: Affinitized/d
  /Store-8079-2: Created proxy context thread/d
  /Store-8079-3: Created retransmission thread/d
  /Store-10682-2: Created auxiliary sending thread/d
  /Store-8079-7: Created proactor thread/d
  /Store-8223-4: Set RegID seed/d
  /Store-5688-5543: Store/d
  /Store-5688-5284: store.*new topic/d
  /Store-5688-5289: store.*existing source/d
  /Store-5688-5293: store.*existing receiver/d
  /Store-8223-5: Reset RegID/d
  /Store-8079-5: Created blocked io thread/d
  /Store-5688-5546: Store.*ready to accept/d
  /Store-8079-4: Created the log offload thread/d
  /Store-8000-101: store.*PREG marker/d
  /Store-10807-100: store.*PREG RESP/d
  /Store-9115-01: store.* BOS/d
  /Store-9115-02: store.* SRI/d
  /Store-5688-5247: rotating file cache/d
' "$@" 
