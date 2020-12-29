import collections
import io
import os
import pprint
import re
import sys


TERMINAL_ENCODING = "utf-8"

class MatchedCommands(object):
    def __init__(self, prefix, lines):
        matched_commands = collections.OrderedDict()
        for line in lines:
            command = self.command_in_history(line)
            if command.startswith(prefix):
                if command in matched_commands:
                    del matched_commands[command]
                matched_commands[command] = True

        lines = list(reversed(matched_commands.keys()))
        self._prefix = prefix
        self._lines = lines
        self._index = 0

    def command_in_history(self, history_line):
        line = history_line.strip("\r\n")
        matched_data = re.match(r"^\s*[0-9]+\s+", line)
        if matched_data is None:
            return ""
        return line[len(matched_data.group(0)):]

    def current_match(self):
        if self._index >= len(self._lines):
            return self._prefix
        else:
            return self._lines[self._index]

    def previous_match(self):
        self._index = (self._index + 1) % (len(self._lines) + 1)
        return self.current_match()

    def next_match(self):
        self._index = (self._index + len(self._lines)) % (len(self._lines) + 1)
        return self.current_match()


def main():
    COMMAND_HISTORY_END = "<history end>\n"
    COMMAND_PREVIOUS_MATCH = "<previous match>\n"
    COMMAND_NEXT_MATCH = "<next match>\n"
    COMMAND_QUIT = "<quit>\n"

    prefix = os.environ["BHSLT_PREFIX"]
    stdin = io.TextIOWrapper(sys.stdin.buffer, encoding=TERMINAL_ENCODING)
    stdout = io.TextIOWrapper(sys.stdout.buffer, encoding=TERMINAL_ENCODING)

    lines = []
    while True:
        line = stdin.readline()
        if line == COMMAND_HISTORY_END:
            break
        lines.append(line)

    matched_commands = MatchedCommands(prefix, lines)
    stdout.write(matched_commands.current_match() + "\n")
    stdout.flush()

    while True:
        line = stdin.readline()
        if line == COMMAND_PREVIOUS_MATCH:
            output = matched_commands.previous_match()
        elif line == COMMAND_NEXT_MATCH:
            output = matched_commands.next_match()
        elif line == COMMAND_QUIT:
            break
        else:
            sys.stderr.write(f"Unknown command: {line}\n")
            raise RuntimeError(f"Unknown command: {line}")
        stdout.write(output + "\n")
        stdout.flush()


if __name__ == "__main__":
    main()
