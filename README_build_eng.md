# How to build a new version of Free Oberon for Linux

The commands are for Debian / Ubuntu.

## Option 1. Download the archive and run the installer

1. On the https://github.com/kekcleader/FreeOberon.git website
   click the green button labeled «Code» and then click «Download ZIP»,
   unpack the archive inside your home directory.
   You can rename directory `FreeOberon-main` to `FreeOberon`.

2. Inside the unpacked directory, run `install.sh` with root privileges.

```
su
./install.sh
```

## Option 2. Build Free Oberon manually

1. Install Git, Gcc and Allegro5:
```
apt-get install -y liballegro5-dev git gcc
```

2. Clone the Free Oberon repository:
```
git clone https://github.com/kekcleader/FreeOberon.git
```

3. Clone the OfrontPlus repository using the submodule update command:

```
cd FreeOberon
git submodule update --init
```

The `FreeOberon/Data/bin/OfrontPlus` directory will be filled with files.

4. Build OfrontPlus:

```
cd Data/bin/OfrontPlus/Target/Linux_amd64/Bin
./build

cd ../../../../../../..
```

5. Build Free Oberon:

```
cd FreeOberon/src
./make.sh
```

6. Run FreeOberon.

This is done from the directory where the executable file `FreeOberon` is located.
```
./FreeOberon
```

Document updated January 27, 2022.
