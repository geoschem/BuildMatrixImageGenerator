# BuildMatrixImageGenerator
This is a Dockerfile and makefile for building the GEOS-Chem build matrix images. These scripts are not robust and will likely need tweaks/updates.

## Requirements
- Docker >= 18.09

## Building the build matrix images
You should generate the build matrix images on your local machine. Clone this repo:
```console
$ git clone https://github.com/geoschem/BuildMatrixImageGenerator.git
```
Navigate into the directory and run make all
```console
$ make -j4 all
```

On my local machine, I find `-j4` is enough for me to hit 100% CPU utilization most of the time. This will take several hours to complete.

## Seeing built images
Search for the images matching the Docker repo's name (there will be more than what's displayed below; this was ran midway through building all):
```console
$ docker images liambindle/bmi
REPOSITORY       TAG             IMAGE ID       CREATED             SIZE
liambindle/bmi   esmf-gcc8.3     bcf06f951e6d   23 minutes ago      1.99GB
liambindle/bmi   esmf-ubuntu     7b9fdb9453e7   35 minutes ago      1.23GB
liambindle/bmi   netcdf-gcc8.3   c4153fce6327   46 minutes ago      1.69GB
liambindle/bmi   netcdf-ubuntu   b9592d2880d2   About an hour ago   925MB
```
