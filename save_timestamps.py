import os
import sys
import json
import hashlib
import argparse

TIMESTAMPSFILE='timestamps.json'

# https://gist.github.com/rji/b38c7238128edf53a181
def sha256_checksum(filename, block_size=65536):
    sha256 = hashlib.sha256()
    with open(filename, 'rb') as f:
        for block in iter(lambda: f.read(block_size), b''):
            sha256.update(block)
    return sha256.hexdigest()

def get_mtime(fname):
    return os.stat(fname).st_mtime

def print_nicely(filedir_info_json):
    from datetime import datetime
    with open(TIMESTAMPSFILE, 'r') as handle:
        parsed = json.load(handle)

        print(">> Directories:")
        for d in parsed['dirs']:
            dname = d['name']
            mtime = datetime.fromtimestamp(d['mtime']).strftime("%Z - %Y/%m/%d, %H:%M:%S")
            print("Name: {0}\nInfo: MTIME: {1}\n".format(dname, mtime))

        print(">> Files (flat list):")
        for f in parsed['files']:
            fname = f['name']
            mtime = datetime.fromtimestamp(f['mtime']).strftime("%Y/%m/%d, %H:%M:%S")
            cksum = f['cksum']
            print("Name: {0}\nInfo: MTIME: {1};\nchecksum: {2}\n".format(fname, mtime, cksum))
        print("End of list")

def traverse_gendict(dirName):
    filedir_info = {'dirs':[], 'files':[]}
    for root, dirs, files in os.walk(dirName):
        for dd in dirs:
            dir_fullpath = os.path.join(root, dd)
            mtime = get_mtime(dir_fullpath)
            filedir_info['dirs'].append({'name':dir_fullpath, 'mtime':mtime})
        for ff in files:
            file_fullpath = os.path.join(root, ff)
            cksum = sha256_checksum(file_fullpath)
            mtime = get_mtime(file_fullpath)
            filedir_info['files'].append({'name':file_fullpath, 'cksum':cksum, 'mtime':mtime})
    return filedir_info

def gen_timestamps():
    try:
        fp = open(TIMESTAMPSFILE, 'w')
    except IOError:
        print("Cannot open timestamps file. Exiting")
        return 1

    print("Looking up files and directories...")

    filedir_info = traverse_gendict(os.path.curdir)

    print("Writing info to ", TIMESTAMPSFILE)
    json.dump(filedir_info, fp)
    fp.close()

def restore_timestamps(force_restore=False):
    pass

def list_diffs():
    pass

parser = argparse.ArgumentParser()
arg_group = parser.add_mutually_exclusive_group()
arg_group.add_argument('-g', '--gen', action='store_true', help='Generate or update JSON of mtime timestamps of files in current directory')
arg_group.add_argument('--restore', action='store_true', help='Restore timestamps from file timestamps.json')
arg_group.add_argument('-l','--list-diff', action='store_true', help='List files and dirs with changes mtime')
arg_group.add_argument('-p','--print-info', action='store_true', help='Print saved info about timestmps')
parser.add_argument('-f', '--force', action='store_true', help='Do not ask questions')

args = parser.parse_args()
args_parsed = vars(args)

if args_parsed['gen']:
    print("Generating timestamps...")
    gen_timestamps()
elif args_parsed['restore']:
    print("Restoring timestamps...")
    restore_timestamps(force_restore=args_parsed['force'])
elif args_parsed['list_diff']:
    list_diffs()
elif args_parsed['print_info']:
    print_nicely(TIMESTAMPSFILE)
