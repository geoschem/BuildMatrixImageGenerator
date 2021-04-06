. /opt/spack/share/spack/setup-env.sh
set -x
set -e

export CC=gcc
export CXX=g++
export FC=gfortran
spack load mpi
spack load hdf5 
spack load netcdf-c
spack load netcdf-fortran
spack load esmf

TEMPDIR=$(mktemp -d)
cd $TEMPDIR
git clone https://github.com/geoschem/GCHP
cd GCHP
git submodule update --init --recursive
mkdir build
cd build
cmake .. -DCMAKE_COLOR_MAKEFILE=FALSE
make -j16
