#!/usr/bin/env python3
"""
msg_id_histo.pl - tool to count log messages of each type and
  print the totals.
  See https://github.com/UltraMessaging/msg_id_histo for full doc.
"""

import argparse
import fileinput
import re


class Main:
    """
    Main program.
    """

    def __init__(self):
        self.msg_id_hist = {}
        self.msg_text_hist = {}
        self.prev_throttled_msg_id = ""
        self.prev_throttled_msg_text = ""

        parser = argparse.ArgumentParser(
            description="Tool to count log messages by type and print totals.",
            epilog="See https://github.com/UltraMessaging/msg_id_histo",
        )
        parser.add_argument(
            "-p",
            "--pattern",
            default=".",
            help="Only count records that match regular pattern.",
        )
        parser.add_argument(
            "-t",
            "--throttled",
            action="store_true",
            help="Don't count omitted throttled logs.",
        )
        parser.add_argument("files", nargs="*", help="Input files (use - for stdin)")

        self.args = parser.parse_args()

    # pylint: disable=too-many-branches
    def process_line(self, line) -> None:
        """Proces one line of log file."""

        if re.search(r"^\s*$", line):
            return  # Ignore blank lines.
        if re.search(r"^\s+", line):
            return  # Ignore lines that start with whitespace.

        # The Gwd-6033-618: message is unfortunate in that it combines many
        # different messages. Differentiate them by the constant parts of
        # the message text.
        match = re.search(r"Gwd-6033-618: (.*)$", line)
        if match:
            msg = match.group(1)
            if re.search(self.args.pattern, line):
                msg = re.sub(r"\[[^\]]*\]", "x", msg)
                msg = re.sub(r"\([^\)]*\)", "x", msg)
                msg_id = f"Gwd-6033-618: {msg}"
                if msg_id not in self.msg_id_hist:
                    self.msg_id_hist[msg_id] = 0
                    self.msg_text_hist[msg_id] = ""
                self.msg_id_hist[msg_id] += 1
            return

        match = re.search(r"previous THROTTLED MSG repeated (\d+) times", line)
        if match:
            throttle_count = int(match.group(1))
            if not self.args.throttled:
                if re.search(self.args.pattern, line):
                    if self.prev_throttled_msg_id != "":
                        # Make sure historgram bucket is defined.
                        if self.prev_throttled_msg_id not in self.msg_id_hist:
                            self.msg_id_hist[self.prev_throttled_msg_id] = 0
                            self.msg_text_hist[self.prev_throttled_msg_id] = (
                                self.prev_throttled_msg_text
                            )
                        self.msg_id_hist[self.prev_throttled_msg_id] += throttle_count

                    else:  # Previous throttled message not found.
                        unknown = "unknown_0:"
                        # Make sure historgram bucket is defined.
                        if unknown not in self.msg_id_hist:
                            self.msg_id_hist[unknown] = 0
                            self.msg_text_hist[unknown] = (
                                "found a 'previous THROTTLED MSG' without a prior 'THROTTLED MSG'"
                            )
                        self.msg_id_hist[unknown] += throttle_count
            return

        line, num_throt_subs = re.subn(r" THROTTLED MSG: ", " ", line)
        match = re.search(r"\]:*\s+([A-Za-z]+-\d+-\d+:)\s+(.*)$", line)
        if match:
            msg_id = match.group(1)
            msg_text = match.group(2)
            if num_throt_subs > 0:
                self.prev_throttled_msg_id = msg_id
                self.prev_throttled_msg_text = msg_text

            if re.search(self.args.pattern, line):
                # Make sure historgram bucket is defined.
                if msg_id not in self.msg_id_hist:
                    self.msg_id_hist[msg_id] = 0
                    self.msg_text_hist[msg_id] = msg_text
                self.msg_id_hist[msg_id] += 1

        else:
            if re.search(self.args.pattern, line):
                print(line)

    def main(self) -> None:
        """Main."""

        with fileinput.input(files=self.args.files) as file_input:
            for line in file_input:
                self.process_line(line.rstrip())

        for msg_id in sorted(self.msg_id_hist.keys()):
            print(
                f"{self.msg_id_hist[msg_id]} - {msg_id} "
                f"{self.msg_text_hist[msg_id]}"
            )


if __name__ == "__main__":
    Main().main()
