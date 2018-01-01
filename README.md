# Game Silo

This is a system for managing a shared instance of game libraries (for example,
Steam SteamApps directory) for simultaneous use on multiple client computers.

It allows you to use the same installation files for a game across
multiple computers.

Files created in an instance will persist across updates of the
master repository, meaning that user's save games and other data stored in game
libraries will be safe.

## Quick Start Guide

1. Clone this repo
2. Create a symlink for easier use

```bash
ln -s /sbin/gamesilo /path/to/repo/gamesilo.sh
```

3. Create a ZFS storage pool + dataset for libraries. Setup Samba and enable usershares
4. Create a library

```bash
# Provide the name of the root dataset,
# a "steam" dataset will be created inside it
gamesilo library create steam zstorage/steam
```

5. Create an instance of a library for a user

```bash
gamesilo instance create steam m1cr0man
```

## Library Management

Gamesilo natively suppots managing multiple game libraries at once.

### Create

Create a new library. The master instance will be created for you.

```bash
gamesilo library create <library> <dataset> <group>
library		Library name
dataset		Library dataset name
group		Group name for files and directories
Example arguments:
		steam zstorage/steam public
```

### Import

Create a new library. The master instance will be created for you.

```bash
gamesilo library
```

### List

Create a new library. The master instance will be created for you.

```bash
gamesilo library
```

## TODO

- Cut out usershare system into it's own subcommand
- Cut out dependency on ZFS, make it generic and add LVM suppot too
