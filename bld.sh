#!/bin/sh
# bld.sh - build the programs on Linux.

# Example: blah; ASSRT "$? -eq 0"
ASSRT() {
  eval "test $1"

  if [ $? -ne 0 ]; then
    echo "ASSRT ERROR, `date`: `basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}, not true: '$1'" >&2
    exit 1
  fi
}  # ASSRT


# Update TOC in doc
for F in *.md; do :
  if egrep "<!-- mdtoc-start -->" $F >/dev/null; then :
    # Update doc table of contents (see https://github.com/fordsfords/mdtoc).
    if which mdtoc.pl >/dev/null; then mdtoc.pl -b "" $F;
    elif [ -x ../mdtoc/mdtoc.pl ]; then ../mdtoc/mdtoc.pl -b "" $F;
    else echo "FYI: mdtoc.pl not found; Skipping doc build"; echo ""; fi
  fi
done


echo ruff format -q msg_id_histo.py
ruff format -q msg_id_histo.py
ASSRT "$? -eq 0"

echo ruff check -q msg_id_histo.py
ruff check -q msg_id_histo.py
ASSRT "$? -eq 0"

echo flake8 msg_id_histo.py
flake8 msg_id_histo.py
ASSRT "$? -eq 0"

echo pylint -sn -r n msg_id_histo.py
pylint -sn -r n msg_id_histo.py
ASSRT "$? -eq 0"
