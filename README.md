# msg_id_histo

Count message IDs from Store and DRO log files

# Table of contents
<!-- mdtoc-start -->
&bull; [msg_id_histo](#msg_id_histo)  
&bull; [Table of contents](#table-of-contents)  
&bull; [Introduction](#introduction)  
&nbsp;&nbsp;&nbsp;&nbsp;&bull; [Tool Set](#tool-set)  
&bull; [msg_id_histo.pl](#msg_id_histopl)  
&bull; [msg_id_histo.py](#msg_id_histopy)  
&nbsp;&nbsp;&nbsp;&nbsp;&bull; [Quick Start](#quick-start)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&bull; [Store](#store)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&bull; [DRO](#dro)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&bull; [Repeat Count](#repeat-count)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&bull; [Sort the Output](#sort-the-output)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&bull; [DRO Gwd-6033-618:](#dro-gwd-6033-618)  
&bull; [dro_filter_log.sh](#dro_filter_logsh)  
&bull; [epoch_log_times.pl](#epoch_log_timespl)  
&bull; [reroute_runs.pl](#reroute_runspl)  
&bull; [COPYRIGHT AND LICENSE](#copyright-and-license)  
<!-- TOC created by '../mdtoc/mdtoc.pl README.md' (see https://github.com/fordsfords/mdtoc) -->
<!-- mdtoc-end -->

# Introduction

This repository holds several tools that the UM support team have
found useful in analyzing UM Store and DRO log files.
These tools are informal and un-polished,
and are offered in the spirit of engineers helping
fellow engineers.
I.e. don't expect the same level of maturity, functionality,
or even quality as the UM product itself. :-)

## Tool Set

* msg_id_histo.pl - Count number of instances of each message type in a Store or DRO log file.
* dro_filter_log.sh - Filter out "normal" logs from a DRO log file.
* epoch_log_times.pl - Prepend epoch time to each Store or DRO log file line.
* reroute_runs.pl - find "runs" of reroute logs in a Store log file.

# msg_id_histo.pl

This simple tool (written in perl) scans a UM Store or DRO log file
and counts the number of ocurrences of the different types of logs,
keyed by the message ID (e.g. "Core-0001-1:").

It will also print the text of the message - the first instance it finds.
For example, if a DRO log file contains a series of Core-6259-2: route
discovery messages with different IP addresses,
they will all be counted towards the Core-6259-2: total,
and the displayed text will be from the first instance found.

The tool is simple,
but I have used it enough times that I think it deserves its own repo.
If you know your way around perl regular expression matching,
it can be pretty easily modified to scan application log files.

# msg_id_histo.py

Python port of Perl tool, for those who prefer Python.

## Quick Start

Download the msg_id_histo repository and copy "msg_id_histo.pl" into your PATH.
It is a good idea for you to examine the code to ensure there isn't anything
dangerous in it (it's short and simple enough that it shouldn't take too long).

### Store

Enter:
````
$ msg_id_histo.pl test_store.log
1 - Core-10403-150: Context (0x31b9af0) created with ContextID (54519210) and ContextName [29west_statistics_context]
1 - Core-10403-151: Reactor Only Context (0x19cbcd0) created with ContextID (2996546139) and ContextName [(NULL)]
1 - Core-7911-1: Onload extensions API has been dynamically loaded
2 - Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072
1 - Store-10366-1: Created daemon monitor thread: id[139812939745024]
1 - Store-10761-01: (C) Copyright 2004,2022 Informatica LLC
1 - Store-5688-5268: Linux mamba 3.10.0-1160.36.2.el7.x86_64 #1 SMP Wed Jul 21 11:57:15 UTC 2021 x86_64
1 - Store-5688-5273: Latency Busters Persistent Store version 6.15
1 - Store-5688-5274: UMP 6.15 [UMP-6.15] [64-bit] Build: Oct 22 2022, 01:54:29 ( DEBUG license LBT-RM LBT-RU LBT-IPC LBT-SMX ) WC[PCRE 7.4 2007-09-21, regex, appcb] HRT[gettimeofday()]
1 - Store-5688-5445: WARNING: store "store_topic1" cache directory appears to be on an NFS mount. This is not recommended.
1 - Store-5688-5447: WARNING: store "store_topic1" state directory appears to be on an NFS mount. This is not recommended.
1 - Store-8079-10: Starting store "store_topic1"
1 - Store-9689-2: LBM XML configuration file [um.xml] specified, but no application-name provided. Setting application name to "umestored"
````

### DRO

Enter:
````
$ msg_id_histo.pl test_dro.log
[2023-06-22 18:07:22.941700] [emergency] FATAL: failed assertion [portal->peer.rcv_msg_state!=NULL] at line 3004 in ../../../../src/gateway/tnwgpeer.c
2 - Core-10403-150: Context (0x33ab660) created with ContextID (1572336232) and ContextName [29west_statistics_context]
2 - Core-10403-151: Reactor Only Context (0x3bd2bf0) created with ContextID (2010954288) and ContextName [(NULL)]
26 - Core-5688-3373: No active resolver instances, sending via inactive instance
1 - Core-7911-1: Onload extensions API has been dynamically loaded
2 - Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072
1 - Gwd-10761-01: (C) Copyright 2004,2022 Informatica LLC
2 - Gwd-6033-618: peer portal [PEER1] failed to connect to peer at [10.55.35.120:10190] via [10.237.176.219]
1 - Gwd-7136-1: Ultra Messaging Gateway version 6.15
1 - Gwd-7136-2: UMP 6.15 [UMP-6.15] [64-bit] Build: Oct 22 2022, 01:54:29 ( DEBUG license LBT-RM LBT-RU LBT-IPC LBT-SMX ) WC[PCRE 7.4 2007-09-21, regex, appcb] HRT[gettimeofday()]
````

Notice the line "[2023-06-22 18:07:22.941700] [emergency] FATAL: failed assertion..."
The tool is not able to find a message ID in that line, so it prints it before
printing message counts.

### Repeat Count

If you examine the "test_dro.log" you will find that it does NOT contain 26
instances of Core-5688-3373.
However, note that it is "throttled" log, meaning that UM suppresses logs that
come out in rapid succession.

In the DRO example log:
````
[2022-10-22 12:18:56.713898] [warning] THROTTLED MSG: Core-5688-3373: No active resolver instances, sending via inactive instance
[2022-10-22 12:18:56.813898] [information] Gwd-6033-618: peer portal [PEER1] failed to connect to peer at [10.55.35.120:10190] via [10.237.176.219]
[2022-10-22 12:18:56.913898] [information] Gwd-6033-618: peer portal [PEER2] failed to connect to peer at [10.55.35.118:10190] via [10.237.176.219]
[2022-10-22 12:18:56.993898] [warning] ...previous THROTTLED MSG repeated 25 times in 1 seconds
````
The tool counts the first instance of Core-5688-3373,
and then adds 25 to it when it sees the "repeated 25 times" log.
(It has to remember what the previous *throttled* message was.)

You can prevent the tool from adding in the "repeated X time" by passing the "-t" option:
````
$ msg_id_histo.pl -t test_dro.log
[2023-06-22 18:07:22.941700] [emergency] FATAL: failed assertion [portal->peer.rcv_msg_state!=NULL] at line 3004 in ../../../../src/gateway/tnwgpeer.c
2 - Core-10403-150: Context (0x33ab660) created with ContextID (1572336232) and ContextName [29west_statistics_context]
2 - Core-10403-151: Reactor Only Context (0x3bd2bf0) created with ContextID (2010954288) and ContextName [(NULL)]
1 - Core-5688-3373: No active resolver instances, sending via inactive instance
1 - Core-7911-1: Onload extensions API has been dynamically loaded
2 - Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072
1 - Gwd-10761-01: (C) Copyright 2004,2022 Informatica LLC
2 - Gwd-6033-618: peer portal [PEER1] failed to connect to peer at [10.55.35.120:10190] via [10.237.176.219]
1 - Gwd-7136-1: Ultra Messaging Gateway version 6.15
1 - Gwd-7136-2: UMP 6.15 [UMP-6.15] [64-bit] Build: Oct 22 2022, 01:54:29 ( DEBUG license LBT-RM LBT-RU LBT-IPC LBT-SMX ) WC[PCRE 7.4 2007-09-21, regex, appcb] HRT[gettimeofday()]
````

### Sort the Output

The output is sorted by the message ID.
I often find it useful to re-sort it by the count:
````
$ msg_id_histo.pl test_dro.log | sort -n
[2023-06-22 18:07:22.941700] [emergency] FATAL: failed assertion [portal->peer.rcv_msg_state!=NULL] at line 3004 in ../../../../src/gateway/tnwgpeer.c
1 - Core-7911-1: Onload extensions API has been dynamically loaded
1 - Gwd-10761-01: (C) Copyright 2004,2022 Informatica LLC
1 - Gwd-7136-1: Ultra Messaging Gateway version 6.15
1 - Gwd-7136-2: UMP 6.15 [UMP-6.15] [64-bit] Build: Oct 22 2022, 01:54:29 ( DEBUG license LBT-RM LBT-RU LBT-IPC LBT-SMX ) WC[PCRE 7.4 2007-09-21, regex, appcb] HRT[gettimeofday()]
2 - Core-10403-150: Context (0x33ab660) created with ContextID (1572336232) and ContextName [29west_statistics_context]
2 - Core-10403-151: Reactor Only Context (0x3bd2bf0) created with ContextID (2010954288) and ContextName [(NULL)]
2 - Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072
2 - Gwd-6033-618: peer portal [PEER1] failed to connect to peer at [10.55.35.120:10190] via [10.237.176.219]
26 - Core-5688-3373: No active resolver instances, sending via inactive instance
````
Note the "-n".
The most-often logged messages are at the bottom.

### DRO Gwd-6033-618:

The DRO message ID "Gwd-6033-618:" deviates from the normal UM model of
having the message ID represent a given message type.
Instead, "Gwd-6033-618:" represents a wide range of messages.
So it is treated differently in the tool, including the constant
parts of the messages as part of the message ID.
Therefore, you can get multiple message counts for differnt "Gwd-6033-618:"
messages.
The variable parts of the message texts are replaced with "x".

For example:
````
$ msg_id_histo.pl 618.log
140 - Gwd-6033-618: peer portal x connected to x
925 - Gwd-6033-618: peer portal x detected dropped inbound connection x
307 - Gwd-6033-618: peer portal x failed to connect to peer at x via x
30 - Gwd-6033-618: peer portal x failed to create peer accept socket x: CoreApi-5688-3231: TCP server bind x: x Address already in use
925 - Gwd-6033-618: peer portal x inbound connection destroyed due to disconnect
119 - Gwd-6033-618: peer portal x inbound connection destroyed due to shutdown
121 - Gwd-6033-618: peer portal x lost connection to peer at x via x
119 - Gwd-6033-618: peer portal x outbound connection destroyed due to shutdown
110 - Gwd-6033-618: peer portal x received connection from x
````

# dro_filter_log.sh

The "dro_filter_log.sh" script contains a simple 'sed' stript that removes "normal"
logs from a DRO log file.
I.e. if "dro_filter_log.sh" scans a DRO log file and generates no output,
you can feel pretty confident that the DRO ran without incident.
Any output lines deserve to be investigated.

It is not unusual to use 'dro_filter_log.sh' in conjunction with 'msg_id_histo.pl':
````
$ dro_filter_log.sh dro.log >dro_errs.log
$ wc dro_errs.log
  59917  974777 9408112 dro_errs.log
````
Almost 60k lines of errors. Hard to digest. Let's get a historgram
````
$ msg_id_histo.pl dro_errs.log >dro_histo.log
$ wc dro_histo.log
  33  445 3318 dro_histo.log
````
33 lines of histogram. Much easier to examine.
````
$ cat dro_histo.log
241 - Core-5688-1890: handle events returned error 5 [CoreApi-5688-3313: TCP server accept: (130) Software caused connection abort]
3 - Core-5688-27: WARNING: receiver config variable retransmit_request_generation_interval is deprecated. Use retransmit_request_message_timeout instead.
127 - Core-5688-3336: lbm_socket_sendb: msg dropped (EWOULDBLOCK): adjust rate limit or buffers
11257 - Core-5688-3373: No active resolver instances, sending via inactive instance
373 - Core-5688-3375: unicast resolver 10.237.176.219:15380 went inactive
373 - Core-5688-3376: received data from inactive unicast resolver 10.237.176.219:15380, marking as active
4897 - Core-5688-3929: No more messages in TCP buffer before old message is complete.
339 - Core-5688-3930: New unfragged message in TCP buffer before old fragged message is complete.
9 - Core-5688-3931: New message in TCP buffer before old message is complete.
11 - Core-5688-445: LBMC datagram malformed, msglen 0. Dropping. Origin: 10.55.35.118:10190
7 - Core-5688-450: LBMC version incorrect (9). Dropping. Origin: 10.55.35.118:10190.
2 - Core-5688-451: LBMC type not supported (12). Dropping. Origin: 10.55.35.118:10190.
1 - Core-5688-452: LBMC basic header too short, dropping message. Origin: 10.55.35.118:10190
1 - Core-5688-468: LBMC unknown next header ff, dropping message. Origin: 10.55.35.118:10190
11 - Core-5894-2: lbm_timer_expire: Exceeded 500 timer expirations in one iteration
3 - Core-6259-1: Re-routing Domain ID 2: old: 10.237.176.57:14702 new: 10.237.176.57:14725
241 - Gwd-6033-368: endpoint portal [PROXY1-TCP] receive context lbm_context_process_events() failed [5]: CoreApi-5688-3313: TCP server accept: (130) Software caused connection abort
3 - Gwd-6033-387: error starting portal [PROXY1-CHANNEL2] [5]: CoreApi-5688-3231: TCP server bind (port=10190): (125) Address already in use
3 - Gwd-6033-492: peer portal [PROXY1-CHANNEL2] unable to start peer connection [5]: CoreApi-5688-3231: TCP server bind (port=10190): (125) Address already in use
3 - Gwd-6033-539: peer portal [PROXY1-CHANNEL2] received one or more UIM data messages with no stream information - these will be dropped
3 - Gwd-6033-618: peer portal x detected dropped inbound connection x
52213 - Gwd-6033-618: peer portal x failed to connect to peer at x via x
3 - Gwd-6033-618: peer portal x failed to create peer accept socket x: CoreApi-5688-3231: TCP server bind x: x Address already in use
3 - Gwd-6033-618: peer portal x inbound connection destroyed due to disconnect
4 - Gwd-6033-618: peer portal x inbound connection destroyed due to shutdown
30 - Gwd-6033-618: peer portal x lost connection to peer at x via x
4 - Gwd-6033-618: peer portal x outbound connection destroyed due to shutdown
4 - Gwd-6033-621: peer portal [PROXY1-CHANNEL2] detected no activity from companion in 15000ms, shutting down connection
24 - Gwd-6361-123: portal [PROXY1-LBTRM] could not find path to domain 2. Dropping UIM packet.
37 - Gwd-6361-75: route recalculation backoff has exceeded the specified threshold
6 - Gwd-6945-1: Portal [PROXY1-LBTRM] began enqueueing data
6 - Gwd-6945-3: Portal [PROXY1-LBTRM] completed flushing queue
````

# epoch_log_times.pl

There are times that it is helpful to combine log files from
multiple instances of a daemon,
or even from different daemons.
For example,
we recently had a case where the logs of both Stores and
DROs had useful information and we wanted to put together
a detailed timeline.

But Store and DRO logs use different time stamp formats,
which makes it a difficult and manual process to combine
two files.

The epoch_log_times.pl reads one or more files and simply
prepends a "@" followed by the [epoch time](https://en.wikipedia.org/wiki/Unix_time)
(sometimes called "Unix time").
This represents the number of seconds after the system's "epoch".
I.e. the epoch time is a simple integer.

For example:
````
$ epoch_log_times.pl test_dro.log | head
@1666441136 [2022-10-22 12:18:56.699685] [notice] Core-7911-1: Onload extensions API has been dynamically loaded

@1666441136 [2022-10-22 12:18:56.699721] [information] Gwd-7136-1: Ultra Messaging Gateway version 6.15
@1666441136 [2022-10-22 12:18:56.699738] [information] Gwd-7136-2: UMP 6.15 [UMP-6.15] [64-bit] Build: Oct 22 2022, 01:54:29 ( DEBUG license LBT-RM LBT-RU LBT-IPC LBT-SMX ) WC[PCRE 7.4 2007-09-21, regex, appcb] HRT[gettimeofday()]
@1666441136 [2022-10-22 12:18:56.699747] [information] Gwd-10761-01: (C) Copyright 2004,2022 Informatica LLC
    This software and documentation are provided only under a separate license agreement containing restrictions on use and disclosure.
    This software is protected by patents as detailed at https://www.informatica.com/legal/patents.html.
    A current list of Informatica trademarks is available on the web at https://www.informatica.com/trademarks.html.

@1666441136 [2022-10-22 12:18:56.701213] [warning] Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072
$ epoch_log_times.pl test_store.log | head
@1666441138 Sat Oct 22 12:18:58 2022 [NOTICE]: Core-7911-1: Onload extensions API has been dynamically loaded
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-5688-5273: Latency Busters Persistent Store version 6.15
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-5688-5274: UMP 6.15 [UMP-6.15] [64-bit] Build: Oct 22 2022, 01:54:29 ( DEBUG license LBT-RM LBT-RU LBT-IPC LBT-SMX ) WC[PCRE 7.4 2007-09-21, regex, appcb] HRT[gettimeofday()]
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-10761-01: (C) Copyright 2004,2022 Informatica LLC
    This software and documentation are provided only under a separate license agreement containing restrictions on use and disclosure.
    This software is protected by patents as detailed at https://www.informatica.com/legal/patents.html.
    A current list of Informatica trademarks is available on the web at https://www.informatica.com/trademarks.html.
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-5688-5268: Linux mamba 3.10.0-1160.36.2.el7.x86_64 #1 SMP Wed Jul 21 11:57:15 UTC 2021 x86_64
@1666441138 Sat Oct 22 12:18:58 2022 [NOTICE]: Store-9689-2: LBM XML configuration file [um.xml] specified, but no application-name provided. Setting application name to "umestored"
@1666441138 Sat Oct 22 12:18:58 2022 [WARNING]: Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072$ 
````

These can now be properly interleaved as follows:
````
$ epoch_log_times.pl test_store.log test_dro.log | sort -k1,1 -s









    A current list of Informatica trademarks is available on the web at https://www.informatica.com/trademarks.html.
    A current list of Informatica trademarks is available on the web at https://www.informatica.com/trademarks.html.
    This software and documentation are provided only under a separate license agreement containing restrictions on use and disclosure.
    This software is protected by patents as detailed at https://www.informatica.com/legal/patents.html.
    This software and documentation are provided only under a separate license agreement containing restrictions on use and disclosure.
    This software is protected by patents as detailed at https://www.informatica.com/legal/patents.html.
@1666441136 [2022-10-22 12:18:56.699685] [notice] Core-7911-1: Onload extensions API has been dynamically loaded
@1666441136 [2022-10-22 12:18:56.699721] [information] Gwd-7136-1: Ultra Messaging Gateway version 6.15
@1666441136 [2022-10-22 12:18:56.699738] [information] Gwd-7136-2: UMP 6.15 [UMP-6.15] [64-bit] Build: Oct 22 2022, 01:54:29 ( DEBUG license LBT-RM LBT-RU LBT-IPC LBT-SMX ) WC[PCRE 7.4 2007-09-21, regex, appcb] HRT[gettimeofday()]
@1666441136 [2022-10-22 12:18:56.699747] [information] Gwd-10761-01: (C) Copyright 2004,2022 Informatica LLC
@1666441136 [2022-10-22 12:18:56.701213] [warning] Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072
@1666441136 [2022-10-22 12:18:56.704070] [information] Core-10403-150: Context (0x33ab660) created with ContextID (1572336232) and ContextName [29west_statistics_context]
@1666441136 [2022-10-22 12:18:56.704437] [warning] Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072
@1666441136 [2022-10-22 12:18:56.710854] [information] Core-10403-151: Reactor Only Context (0x3bd2bf0) created with ContextID (2010954288) and ContextName [(NULL)]
@1666441136 [2022-10-22 12:18:56.711083] [information] Core-10403-151: Reactor Only Context (0x3bebbf0) created with ContextID (846209105) and ContextName [(NULL)]
@1666441136 [2022-10-22 12:18:56.713898] [information] Core-10403-150: Context (0x3c05550) created with ContextID (199802605) and ContextName [TRD1]
@1666441136 [2022-10-22 12:18:56.713898] [warning] THROTTLED MSG: Core-5688-3373: No active resolver instances, sending via inactive instance
@1666441136 [2022-10-22 12:18:56.813898] [information] Gwd-6033-618: peer portal [PEER1] failed to connect to peer at [10.55.35.120:10190] via [10.237.176.219]
@1666441136 [2022-10-22 12:18:56.913898] [information] Gwd-6033-618: peer portal [PEER2] failed to connect to peer at [10.55.35.118:10190] via [10.237.176.219]
@1666441136 [2022-10-22 12:18:56.993898] [warning] ...previous THROTTLED MSG repeated 25 times in 1 seconds
@1666441138 Sat Oct 22 12:18:58 2022 [NOTICE]: Core-7911-1: Onload extensions API has been dynamically loaded
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-5688-5273: Latency Busters Persistent Store version 6.15
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-5688-5274: UMP 6.15 [UMP-6.15] [64-bit] Build: Oct 22 2022, 01:54:29 ( DEBUG license LBT-RM LBT-RU LBT-IPC LBT-SMX ) WC[PCRE 7.4 2007-09-21, regex, appcb] HRT[gettimeofday()]
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-10761-01: (C) Copyright 2004,2022 Informatica LLC
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-5688-5268: Linux mamba 3.10.0-1160.36.2.el7.x86_64 #1 SMP Wed Jul 21 11:57:15 UTC 2021 x86_64
@1666441138 Sat Oct 22 12:18:58 2022 [NOTICE]: Store-9689-2: LBM XML configuration file [um.xml] specified, but no application-name provided. Setting application name to "umestored"
@1666441138 Sat Oct 22 12:18:58 2022 [WARNING]: Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072
@1666441138 Sat Oct 22 12:18:58 2022 [WARNING]: Store-5688-5445: WARNING: store "store_topic1" cache directory appears to be on an NFS mount. This is not recommended.
@1666441138 Sat Oct 22 12:18:58 2022 [WARNING]: Store-5688-5447: WARNING: store "store_topic1" state directory appears to be on an NFS mount. This is not recommended.
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-10366-1: Created daemon monitor thread: id[139812939745024]
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Core-10403-151: Reactor Only Context (0x19cbcd0) created with ContextID (2996546139) and ContextName [(NULL)]
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Store-8079-10: Starting store "store_topic1"
@1666441138 Sat Oct 22 12:18:58 2022 [INFO]: Core-10403-150: Context (0x31b9af0) created with ContextID (54519210) and ContextName [29west_statistics_context]
@1666441138 Sat Oct 22 12:18:58 2022 [WARNING]: Core-9941-2212: specified smart source retention buffer count of 101000 will be increased to the next highest power of two: 131072
@1687457242 [2023-06-22 18:07:22.941700] [emergency] FATAL: failed assertion [portal->peer.rcv_msg_state!=NULL] at line 3004 in ../../../../src/gateway/tnwgpeer.c
````
The test logs don't do the best job of demonstrating the feature,
but notice that the DRO fatal assert in 2023 is ordered after the Store logs in 2022.
Also note that for Store logs that have the same timestamp,
the original order is retained.
This is accomplished by the "-s" sort option.

# reroute_runs.pl

This is a special-purpose tool for a customer issue where the UM version 6.5
DRO (which had several bugs, since fixed) sometimes led to network instability.
One symtom of this instability is re-route messages appearing repeatedly
in the Store logs.

But the occasional re-route log is not an indication of instability.
So we wanted a tool that looked for "runs" of re-route messages and
kept track of the start and end times of a run, and the number of
re-routes in the run.

A "run" is defined by a set of re-route events that are separated by
less than "-t threshold" seconds (defaults to 60).
Thus, a large number of frequent re-routes spanning an extended time
will be reported as a single run, with the number of events and the
time span reported.

Note that a re-route "event" is not simply a single instance of
a re-route log message.
This is because the Store has two contexts,
each of which will report a given re-route.
Also, a re-route event can affect multiple TRDs.
So a single re-route "event" can consist of
many log lines.

An imperfect but simple way to count the re-route events is to
assume that re-routes that happen in the same second are all part
of the same event.
So the following logs are counted as three events in a single run:
````
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.118:14702 new: 10.55.35.120:14702
````

The tool also is intended to suppress runs that are short-lived.
For a run to be reported, it must last at least
"-d duration_min_report" seconds (defaults to 10) and
contain at least "-n num_min_report" re-route events (defaults to 10).
The above example will not be reported because even though it lasted 26 seconds,
it only contains 3 re-route events.

But you can tell the tool to report all runs, regarless of size, as follows:
````
$ reroute_runs.pl -d 1 -n 1 <<__EOF__
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:32 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:38 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.120:14702 new: 10.55.35.118:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 1: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 3: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.118:14702 new: 10.55.35.120:14702
Mon Oct 19 04:31:58 2020 [INFO]: Core-6259-1: Re-routing Domain ID 5: old: 10.55.35.118:14702 new: 10.55.35.120:14702
__EOF__
3 re-route events Mon Oct 19 04:31:32 2020 to Mon Oct 19 04:31:58 2020 (26 sec)
````

# COPYRIGHT AND LICENSE

We want there to be NO barriers to using this code,
so we are releasing it to the public domain.
But "public domain" does not have an internationally agreed upon definition,
so we use CC0:

Copyright 2023 Informatica and licensed
"public domain" style under
[CC0](http://creativecommons.org/publicdomain/zero/1.0/):
![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png "CC0")

To the extent possible under law, the contributors to this project have
waived all copyright and related or neighboring rights to this work.
In other words, you can use this code for any purpose without any
restrictions.  This work is published from: United States.  The project home
is https://github.com/UltraMessaging/msg_id_histo

This source code example is provided by Informatica for educational
and evaluation purposes only.

THE SOFTWARE IS PROVIDED "AS IS" AND INFORMATICA DISCLAIMS ALL WARRANTIES
EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF
NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR
PURPOSE.  INFORMATICA DOES NOT WARRANT THAT USE OF THE SOFTWARE WILL BE
UNINTERRUPTED OR ERROR-FREE.  INFORMATICA SHALL NOT, UNDER ANY CIRCUMSTANCES,
BE LIABLE TO LICENSEE FOR LOST PROFITS, CONSEQUENTIAL, INCIDENTAL, SPECIAL OR
INDIRECT DAMAGES ARISING OUT OF OR RELATED TO THIS AGREEMENT OR THE
TRANSACTIONS CONTEMPLATED HEREUNDER, EVEN IF INFORMATICA HAS BEEN APPRISED OF
THE LIKELIHOOD OF SUCH DAMAGES.
