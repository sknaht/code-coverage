"""
This script deals with Code Coverage result files.
"""

import sys

# input file name
f = open(sys.argv[1])
keywords = [key for key in sys.argv[2:]]
print keywords
fo = open('tmp.info', "w")


while True:
    s = f.readline()

    if s == '':
        break

    data = [s]
    while True:
        s = f.readline()
        if "_block" in s or ('_Block' in s) or ('_destruct' in s):
            continue

        data.append(s)

        if "end_of_record" in s:
            for key in keywords:
                if (key in (data[0] + data[1]).lower()):
                    fo.writelines(data)
                    break
            break

fo.close()
f.close()
