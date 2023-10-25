import sys
from ConfigParser import ConfigParser

sec_common = 'List'
driver_prefix = 'Driver_'
ignored_sections = ['Driver_DRVBIG', 'Driver_DRVSMALL', 'Driver_COMMON']

if len(sys.argv) < 2:
    print "Usage: python check_ini.py drivers.gpas.ini"
    sys.exit(1)

c = ConfigParser(allow_no_value=True)
c.read(sys.argv[1])

all_sections = []
section_str_num = []
line_counter = 0
f = open(sys.argv[1])
for line in f.readlines():
    line_counter = line_counter + 1
    if line[0] != "#":
        if line[0] == "[":
            end_sect_name = line.find("]")
            if end_sect_name != -1:
                all_sections.append(line[0:end_sect_name+1].lower())
                section_str_num.append(line_counter)
f.close()

duplicate_sections = []
i = 0
while i < len(all_sections):
    if all_sections.count(all_sections[i]) > 1:
        duplicate_sections.append(
          "{} line {}  {}".format(sys.argv[1], section_str_num[i], all_sections[i])
        )
    i = i + 1

menu_items = set(c.get(sec_common, 'Drivers').split(';'))
section_items = set([
    x[len(driver_prefix):] for x in c.sections()
    if (x not in ignored_sections) and (x.startswith(driver_prefix))
])

errlevel = 0
menu_diff = menu_items.difference(section_items)
section_diff = section_items.difference(menu_items)

if duplicate_sections:
    print "Duplicate sections Drivers ids:"
    for x in duplicate_sections:
        print "{}".format(x)

    errlevel = 1

if menu_diff:
    print sys.argv[1], "No corresponding sections for next [List] Drivers ids:"
    for x in menu_diff:
        print "{}".format(x)

    errlevel = 1

if section_diff:
    print sys.argv[1], "No corresponding [List] Drivers ids for next sections:"
    for x in section_diff:
        print "[{}{}]".format(driver_prefix, x)

    errlevel = 1


def Serch_key_in_section(key_for_search):
    key_not_define = []
    res_err = 0

    for cur_section in section_items:
        try:
            cur_section = driver_prefix + cur_section
            c.get(cur_section, key_for_search)
        except Exception:
            key_not_define.append(cur_section)

    if len(key_not_define) > 0:
        print 'key {} not defined in sections:'.format(key_for_search)
        for cur_section in key_not_define:
            print "[{}]".format(cur_section)
        res_err = 1

    return res_err


if Serch_key_in_section('DriverSource') > 0:
    errlevel = 1
if Serch_key_in_section('Path') > 0:
    errlevel = 1
if Serch_key_in_section('Description') > 0:
    errlevel = 1


description_list = []
for cur_section in section_items:
    try:
        cur_section = driver_prefix + cur_section
        description_value = c.get(cur_section, 'Description')
        description_list.append((cur_section, description_value))

    except Exception:
        nu_vot_tak = 1

description_list_length = len(description_list)
duplicate_description_list = []
if description_list_length > 1:
    cur_pos = -1
    for cur_description in description_list:
        cur_pos = cur_pos + 1
        next_pos = cur_pos
        while next_pos < description_list_length-1:
            next_pos = next_pos + 1
            next_description = description_list[next_pos]
            if cur_description[1] == next_description[1]:
                duplicate_description_list.append(cur_description[0])

                description_list.remove(next_description)
                description_list_length = description_list_length - 1

                errlevel = 1

duplicate_sect_list = set(duplicate_description_list)
if len(duplicate_sect_list) > 0:
    print 'Duplicate key Description in this sections'
    for cur_duplicate in duplicate_sect_list:
        print '[{}]'.format(cur_duplicate)

sys.exit(errlevel)
