"""
This script deals with Code Coverage result files.
"""

import sys

# input file name
f = open(sys.argv[1])
fo = open('uncovered_functions.info', "w")


while True:
    s = f.readline()

    if s == '':
        break

    if "FN:" in s or "FNDA:" in s:
        if ':0,' not in s:
            continue

    fo.write(s)


fo.close()
f.close()
