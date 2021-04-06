export DOCKER_BUILDKIT=1

help:           ## Show this help.
	@echo 'Build GEOS-Chem build matrix images.'
	@echo ' '
	@echo ' There are two types of images targets: ESMF images, and NetCDF images. ESMF'
	@echo ' images are suitable for building GCHP, NetCDF images are suitable for building'
	@echo ' GC-Classic.'
	@echo ' '
	@echo ' TARGETS'
	@echo '   all                   Builds all the images (this takes a few hours). '
	@echo '   esmf-mpi-variants     Builds ESMF images for multiple MPI variants. '
	@echo '   oldest-cmake          Builds an ESMF image with the oldest version of CMake'
	@echo '                          that GCHP supports.'
	@echo '   gccX.Y                Builds an ESMF and NetCDF images for GCC compiler version'
	@echo '                          X.Y (see gcc base image tags for supported versions). '
	@echo '   ubuntu                Builds Ubuntu-based ESMF and NetCDF images.'
	@echo '   centos                Builds CentOS-based ESMF and NetCDF images.'
	@echo ' '
	@echo ' TESTING'
	@echo '   A simple integration test can be ran with "make test". '
	@echo ' '
	@echo ' NOTES'
	@echo '   * You build these images on your local machine (it uses docker build). '
	@echo '   * It may take a few hours to build each images. '
	@echo '   * These scripts are not robust. Tweaks and updates are probably going to be '
	@echo '      necessary. '


gcc%:
	docker build . --build-arg BASE_IMAGE=gcc --build-arg GCC_VERSION=$* 
	docker build . --build-arg BASE_IMAGE=gcc --build-arg GCC_VERSION=$* --target esmf -t "geoschem/buildmatrix:esmf-$@"
	docker build . --build-arg BASE_IMAGE=gcc --build-arg GCC_VERSION=$* --target netcdf -t "geoschem/buildmatrix:netcdf-$@"

esmf_slim-openmpi-%:
	{ \
		SPACK_ESMF_SPEC='esmf target=x86_64 -lapack -pio -pnetcdf -xerces ^openmpi@$*' ; \
		echo "Building ESMF image with spec: \"$${SPACK_ESMF_SPEC}\"" ; \
		docker build . --build-arg BASE_IMAGE=ubuntu --build-arg SPACK_ESMF_SPEC="$${SPACK_ESMF_SPEC}" --target esmf -t "geoschem/buildmatrix:esmf_slim-openmpi$*-ubuntu" ; \
	}

esmf_slim-mpich-%:
	{ \
		SPACK_ESMF_SPEC='esmf target=x86_64 -lapack -pio -pnetcdf -xerces ^mpich@$*' ; \
		echo "Building ESMF image with spec: \"$${SPACK_ESMF_SPEC}\"" ; \
		docker build . --build-arg BASE_IMAGE=ubuntu --build-arg SPACK_ESMF_SPEC="$${SPACK_ESMF_SPEC}" --target esmf -t "geoschem/buildmatrix:esmf_slim-mpich$*-ubuntu"  ; \
	}

esmf_slim-mvapich-%:
	{ \
		SPACK_ESMF_SPEC='esmf target=x86_64 -lapack -pio -pnetcdf -xerces ^mvapich2@$* fabrics=mrail' ; \
		echo "Building ESMF image with spec: \"$${SPACK_ESMF_SPEC}\"" ; \
		docker build . --build-arg BASE_IMAGE=ubuntu --build-arg SPACK_ESMF_SPEC="$${SPACK_ESMF_SPEC}" --target esmf -t "geoschem/buildmatrix:esmf_slim-mvapich$*-ubuntu" 
	}	
	
%:
	docker build . --build-arg BASE_IMAGE=$@ 
	docker build . --build-arg BASE_IMAGE=$@ --target esmf -t "geoschem/buildmatrix:esmf-$@" 
	docker build . --build-arg BASE_IMAGE=$@ --target netcdf -t "geoschem/buildmatrix:netcdf-$@" 

oldest-cmake:
	{ \
		SPACK_ESMF_SPEC='esmf target=x86_64 -lapack -pio -pnetcdf -xerces ^openmpi@$*' ; \
		echo "Building ESMF image with spec: \"$${SPACK_ESMF_SPEC}\"" ; \
		docker build . --build-arg BASE_IMAGE=ubuntu --build-arg SPACK_UTILS_SPEC=cmake@3.13.5 --build-arg SPACK_ESMF_SPEC="$${SPACK_ESMF_SPEC}" --target esmf -t "geoschem/buildmatrix:esmf_slim-cmake3.13-ubuntu" ; \
	}

test: esmf_slim-openmpi-4.0.1
	docker run -v $(shell pwd)/.github/workflows:/my-volume  geoschem/buildmatrix:esmf_slim-openmpi4.0.1-ubuntu bash /my-volume/test-gchp-build.sh


.PHONY: all esmf-mpi-variants test

esmf-mpi-variants: esmf_slim-openmpi-3.0.4 esmf_slim-openmpi-3.1.4 esmf_slim-openmpi-4.0.1 esmf_slim-mpich-3.1.4 esmf_slim-mpich-3.2.1 esmf_slim-mpich-3.3.1 esmf_slim-mvapich-2.2 esmf_slim-mvapich-2.3.1

all: ubuntu centos gcc8.3 gcc8.4 gcc9.3 gcc10.2 esmf-mpi-variants oldest-cmake # alpine
