#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
From:

``` language codepath
code snippet
```

To:

``` language codepath {prefix}codepath {basename codepath}
code snippet
```
"""

import optparse
import os
import sys


BLOCK_START = '``` '


def translate(n, line, prefix):
    if not line.startswith(BLOCK_START):
        return line
    words = line.split()
    if len(words) != 3:
        return line
    codepath = words[2]
    words.append(prefix + codepath)
    words.append(os.path.basename(codepath))
    linenew = ' '.join(words)
    print('%d: %s' % (n+1, linenew))
    return linenew + '\n'


def codepath(infile, outfile, prefix):
    with open(infile, 'r') as src, open(outfile, 'w') as dest:
        for n, line in enumerate(src):
            dest.write(translate(n, line, prefix))


def _parse_args():
    parser = optparse.OptionParser()
    parser.add_option('-i', '--in', dest='infile', metavar='file',
        help='the input file')
    parser.add_option('-o', '--out', dest='outfile', metavar='file',
        help='the output file')
    parser.add_option('-p', '--prefix', dest='prefix', metavar='https://github.com/',
        help='the codepath prefix')
    options, args = parser.parse_args()
    return options


if __name__ == '__main__':
    options = _parse_args()

    infile = options.infile
    if not infile or not os.path.isfile(infile):
        sys.exit('not found the input file: %s' % infile)

    backup = False

    outfile = options.outfile
    if not outfile:
        backup = True
        outfile = infile + '.temp'

    prefix = options.prefix
    if not prefix:
        sys.exit('not specified prefix')

    codepath(infile, outfile, prefix)

    if backup:
        bakfile = infile + '.bak'
        if os.path.isfile(bakfile):
            os.remove(bakfile)
        os.rename(infile, bakfile)
        os.rename(outfile, infile)
