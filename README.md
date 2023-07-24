# msg_id_histo

Count message IDs from Store and DRO log files

# Table of contents
<!-- mdtoc-start -->
&DoubleRightArrow; [msg_id_histo](#msg_id_histo)  
&DoubleRightArrow; [Table of contents](#table-of-contents)  
&DoubleRightArrow; [Introduction](#introduction)  
&nbsp;&nbsp;&DoubleRightArrow; [Repository](#repository)  
&DoubleRightArrow; [Quick Start](#quick-start)  
&nbsp;&nbsp;&DoubleRightArrow; [Store](#store)  
&nbsp;&nbsp;&DoubleRightArrow; [DRO](#dro)  
&nbsp;&nbsp;&DoubleRightArrow; [Repeat Count](#repeat-count)  
&nbsp;&nbsp;&DoubleRightArrow; [Sort the Output](#sort-the-output)  
&nbsp;&nbsp;&DoubleRightArrow; [DRO Gwd-6033-618:](#dro-gwd-6033-618)  
&nbsp;&nbsp;&DoubleRightArrow; [dro_log.sh](#dro_logsh)  
&DoubleRightArrow; [COPYRIGHT AND LICENSE](#copyright-and-license)  
<!-- TOC created by '../mdtoc/mdtoc.pl README.md' (see https://github.com/fordsfords/mdtoc) -->
<!-- mdtoc-end -->

# Introduction

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

## Repository

See https://github.com/UltraMessaging/msg_id_histo for code and documentation.

# Quick Start

Download the msg_id_histo repository and copy "msg_id_histo.pl" into your PATH.
It is a good idea for you to examine the code to ensure there isn't anything
dangerous in it (it's short and simple enough that it shouldn't take too long).

## Store

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

## DRO

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


## Repeat Count

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

## Sort the Output

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

## DRO Gwd-6033-618:

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

## dro_log.sh

The "dro_log.sh" script contains a simple 'sed' stript that removes "normal"
logs from a DRO log file.
I.e. if "dro_log.sh" scans a DRO log file and generates no output,
you can feel pretty confident that the DRO ran without incident.
Any output lines deserve to be investigated.

It is not unusual to use 'dro_log.sh' in conjunction with 'msg_id_histo.pl':
````
$ dro_log.sh dro.log >dro_errs.log
$ wc dro_errs.log
  59917  974777 9408112 dro_errs.log
```
Almost 60k lines of errors. Hard to digest. Let's get a historgram
```
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


# COPYRIGHT AND LICENSE

All of the documentation and software included in this and any
other Informatica Ultra Messaging GitHub repository
Copyright (C) Informatica. All rights reserved.

Permission is granted to licensees to use
or alter this software for any purpose, including commercial applications,
according to the terms laid out in the Software License Agreement.

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
