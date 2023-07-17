# msg_id_histo

Count message IDs from Store and DRO log files

# Table of contents
<!-- mdtoc-start -->
&DoubleRightArrow; [msg_id_histo](#msgidhisto)  
&DoubleRightArrow; [Table of contents](#table-of-contents)  
&DoubleRightArrow; [Introduction](#introduction)  
&nbsp;&nbsp;&DoubleRightArrow; [Repository](#repository)  
&DoubleRightArrow; [Quick Start](#quick-start)  
&DoubleRightArrow; [COPYRIGHT AND LICENSE](#copyright-and-license)  
<!-- TOC created by '../mdtoc/mdtoc.pl README.md' (see https://github.com/fordsfords/mdtoc) -->
<!-- mdtoc-end -->

# Introduction

This simple tool (written in perl) scans a UM Store or DRO log file
and counts the number of ocurrences of the different types of logs,
keyed by the message ID (e.g. "Core-0001-1:").

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

Also:
````
$ msg_id_histo.pl test_dro.log
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
If you examine the "test_dro.log" you will find that it does NOT contain 26
instances of Core-5688-3373.
However, note that it is "throttled" log, meaning that UM suppresses logs that
come out in rapid succession.
In this example:
````
[2022-10-22 12:18:56.713898] [warning] THROTTLED MSG: Core-5688-3373: No active resolver instances, sending via inactive instance
[2022-10-22 12:18:56.813898] [information] Gwd-6033-618: peer portal [PEER1] failed to connect to peer at [10.55.35.120:10190] via [10.237.176.219]
[2022-10-22 12:18:56.913898] [information] Gwd-6033-618: peer portal [PEER2] failed to connect to peer at [10.55.35.118:10190] via [10.237.176.219]
[2022-10-22 12:18:56.993898] [warning] ...previous THROTTLED MSG repeated 25 times in 1 seconds
````
The tool counts the first instance of Core-5688-3373,
and then adds 25 to it when it sees the "repeated 25 times" log.
(It has to remember what the previous **throttled** message was.)

You can prevent the tool from adding in the "repeated X time" by passing the "-t" option:
````
$ msg_id_histo.pl -t test_dro.log
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
