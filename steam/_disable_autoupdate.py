#!/usr/bin/env python3
from sys import argv
from glob import glob
from os.path import basename, join
from vdf import load, dump, VDFDict

def check_args():
    if len(argv) < 2:
        print('Usage: {} steamapps'.format(basename(argv[0])))
        print('\tsteamapps: Path to steamapps directory')
        return exit(1)
    return argv[1]

def main():
    steamapps = check_args()
    print('Scanning manifests')
    for manifest in glob(join(steamapps, '*.acf')):
        with open(manifest, 'r') as manifile:
            vdf = load(manifile, mapper=VDFDict)
        changed = False

        # Disable autoupdate
        if vdf[0, 'AppState'][0, 'AutoUpdateBehavior'] != '0':
            vdf[0, 'AppState'][0, 'AutoUpdateBehavior'] = '0'
            print('Disabled', vdf[0, 'AppState'][0, 'name'])
            changed = True
        state_flag = int(vdf[0, 'AppState'][0, 'StateFlags'])

        # If it's in ready state make sure state is 4
        # Sometimes it goes to 6 for some reason
        # See https://github.com/lutris/lutris/blob/master/docs/steam.rst
        if state_flag != 4 and state_flag & 4:
            vdf[0, 'AppState'][0, 'StateFlags'] = '4'
            print('Marking as updated', vdf[0, 'AppState'][0, 'name'])
            changed = True
        if changed:
            with open(manifest, 'w') as manifile:
                dump(vdf, manifile, pretty=True)
    print('Done')

if __name__ == '__main__':
    main()
