#!/usr/bin/env python
#
# Encodes data like ARTIQ build_soc.py ReprogrammableIdentifier

import sys

if len(sys.argv) != 2:
    raise ValueError('argument missing')

identifier_str = sys.argv[1]
contents = list(identifier_str.encode())
l = len(contents)
if l > 255:
    raise ValueError("Identifier string must be 255 characters or less")
contents.insert(0, l)

f = sys.stdout
f.write("[\n");
for i in range(7):
    init = sum(1 << j if c & (1 << i) else 0 for j, c in enumerate(contents))
    f.write(
        '  {{ cell = "identifier_str{}"; init = "256\'h{:X}"; }}\n'.format(i, init)
    )
f.write("]\n");
