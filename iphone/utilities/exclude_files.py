"""
This script deals with Code Coverage result files.
"""

import sys

# input file name
excluded_files = open("excluded_files")
keywords = excluded_files.readlines()
excluded_files.close()

f = open(sys.argv[1])
fo = open(sys.argv[2], 'w')

while True:
    s = f.readline()

    if s == '':
        break

    data = [s]
    while True:
        s = f.readline()
        data.append(s)

        if "end_of_record" in s:
            for key in keywords:
                if (key in (data[0] + data[1]).lower()):
                    break
            fo.writelines(data)
            break

fo.close()
f.close()
