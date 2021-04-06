# BuildMatrixImageGenerator
[![Docker](https://github.com/geoschem/BuildMatrixImageGenerator/actions/workflows/build-test.yml/badge.svg)](https://github.com/geoschem/BuildMatrixImageGenerator/actions/workflows/build-test.yml)

This is a Dockerfile and makefile for building the GEOS-Chem build matrix images. These scripts are not robust and will likely need tweaks/updates.

```console
$ make help
Build GEOS-Chem build matrix images.
 
 There are two types of images targets: ESMF images, and NetCDF images. ESMF
 images are suitable for building GCHP, NetCDF images are suitable for building
 GC-Classic.
 
 TARGETS
   all                   Builds all the images (this takes a few hours). 
   esmf-mpi-variants     Builds ESMF images for multiple MPI variants. 
   oldest-cmake          Builds an ESMF image with the oldest version of CMake
                          that GCHP supports.
   gccX.Y                Builds an ESMF and NetCDF images for GCC compiler version
                          X.Y (see gcc base image tags for supported versions). 
   ubuntu                Builds Ubuntu-based ESMF and NetCDF images.
   centos                Builds CentOS-based ESMF and NetCDF images.
 
 TESTING
   A simple integration test can be ran with "make test". 
 
 NOTES
   * You build these images on your local machine (it uses docker build). 
   * It may take a few hours to build each images. 
   * These scripts are not robust. Tweaks and updates are probably going to be 
      necessary. 
```

## Requirements
- Docker >= 18.09

## How to run
Clone this repo to your local machine:
```console
$ git clone https://github.com/geoschem/BuildMatrixImageGenerator.git
```
Step into the repo and run make all:
```console
$ make -j4 all     # -j4 hit's 100% on all CPUs on my machine
```

This will take several hours to complete.

## How to test

A basic integration test can be ran with
```console
$ make test
```
It takes ~1-2 hours to complete.

## How to see the built images
Search for the images matching "geoschem/buildmatrix": (there will be more than what's displayed below; this was ran midway through building all):
```console
$ docker images geoschem/buildmatrix
REPOSITORY             TAG                             IMAGE ID       CREATED         SIZE
geoschem/buildmatrix   esmf_slim-openmpi4.0.1-ubuntu   2244e719906b   2 minutes ago   1.21GB
geoschem/buildmatrix   esmf-gcc9.3                     ab10c73d6b74   2 hours ago     2.03GB
geoschem/buildmatrix   netcdf-gcc9.3                   cfbc41dc4e5e   2 hours ago     1.73GB
geoschem/buildmatrix   esmf-gcc8.4                     b9c5a145f8eb   3 hours ago     2.01GB
geoschem/buildmatrix   esmf-gcc8.3                     04c42813f844   3 hours ago     2.05GB
geoschem/buildmatrix   esmf-ubuntu                     850c2be85e1b   3 hours ago     1.29GB
geoschem/buildmatrix   netcdf-gcc8.4                   0288e57354c2   3 hours ago     1.71GB
geoschem/buildmatrix   netcdf-gcc8.3                   7741484c4e31   3 hours ago     1.75GB
geoschem/buildmatrix   netcdf-ubuntu                   e5e8312f8257   3 hours ago     986MB
```
