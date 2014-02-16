waxe-works
==========

Support files for building waxe

To rebuild, use:
```
cd build
neko build.n
```

Mac 32-bit binaries are not provided  - it is recommended that you build 64 bit binaries for mac.  However 32-bit binaries cant be built.

Building on linux requires some packages.  Starting from scratch, the following worked - I'm not sure that the g++4.8 step was required.
```
sudo apt-get install g++-4.8 --fix-missing
sudo apt-get install g++ --fix-missing
sudo apt-get install libgtk2.0-dev --fix-missing
sudo apt-get install libxxf86vm-dev --fix-missing
sudo apt-get install libgl1-mesa-dev --fix-missing
```
