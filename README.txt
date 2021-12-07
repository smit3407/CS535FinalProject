# Template code for CS535 Final Assignment

## Overview

My final project for CS535, Intro to Computer Graphics.
This project was to demonstrate using the GPU for processing pixel conditions to do a basic powder physics simulation.

## Setup

### LINUX

1. Make sure you have all dependencies installed.

Debian-based systems (e.g. Ubuntu):
	$ sudo apt install libglm-dev freeglut3-dev

Arch-based systems (e.g. Manjaro):
	$ sudo pacman -Sy glm freeglut

2. Compile
	$ make

3. Run
	$ ./final

### WINDOWS

1. Open Visual Studio
2. Build & run

#### Note

If you have linker errors with freeglut .lib or .dll files, it is
probably due to a compiler mismatch. You can download the latest
FreeGLUT at http://freeglut.sourceforge.net/.