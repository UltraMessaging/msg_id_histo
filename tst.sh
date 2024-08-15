#!/bin/sh
# tst.sh - build the programs on Linux.

echo test_store
./msg_id_histo.pl test_store.log >x.1
./msg_id_histo.py test_store.log >x.2
diff x.1 x.2

echo test_dro
./msg_id_histo.pl test_dro.log >x.1
./msg_id_histo.py test_dro.log >x.2
diff x.1 x.2

