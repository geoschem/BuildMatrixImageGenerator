export DOCKER_BUILDKIT=1

help:           ## Show this help.
	@echo This makefile builds GEOS-Chem build matrix images. The following base images
	@echo \ are available:
	@sed -n 's/FROM .* AS \([a-zA-Z0-9_-]*\)-base/    * \1/p' Dockerfile
	@echo \ Run \"make BASE_IMAGE\" where BASE_IMAGE is one of the images listed above. If 
	@echo \ building gcc, append the version number \(e.g., \"make gcc10.2\"\). The gcc
	@echo \ versions that are supported are the tags of the gcc base image on DockerHub.
	@echo The following targets are also available:
	@echo \ \ \ \ * esmf-mpi-variants


gcc%:
	docker build . --build-arg BASE_IMAGE=gcc --build-arg GCC_VERSION=$* 
	docker build . --build-arg BASE_IMAGE=gcc --build-arg GCC_VERSION=$* --target esmf_full -t "liambindle/bmi:esmf-$@"
	docker build . --build-arg BASE_IMAGE=gcc --build-arg GCC_VERSION=$* --target netcdf -t "liambindle/bmi:netcdf-$@"

esmf_slim-openmpi-%:
	ESMF_SPACK_SPEC="esmf target=x86_64 -lapack -pio -pnetcdf -xerces ^openmpi@$*"
	docker build . --build-arg BASE_IMAGE=alpine --build-arg ESMF_SPACK_SPEC=${ESMF_SPACK_SPEC} --target esmf_custom -t "liambindle/bmi:esmf_slim-openmpi$*-alpine" 

esmf_slim-mpich-%:
	ESMF_SPACK_SPEC="esmf target=x86_64 -lapack -pio -pnetcdf -xerces ^mpich@$*"
	docker build . --build-arg BASE_IMAGE=alpine --build-arg ESMF_SPACK_SPEC=${ESMF_SPACK_SPEC} --target esmf_custom -t "liambindle/bmi:esmf_slim-mpich$*-alpine" 

esmf_slim-mvapich-%:
	ESMF_SPACK_SPEC="esmf target=x86_64 -lapack -pio -pnetcdf -xerces ^mvapich2@$* fabrics=mrail"
	docker build . --build-arg BASE_IMAGE=alpine --build-arg ESMF_SPACK_SPEC=${ESMF_SPACK_SPEC} --target esmf_custom -t "liambindle/bmi:esmf_slim-mvapich$*-alpine" 
	
%:
	docker build . --build-arg BASE_IMAGE=$@ 
	docker build . --build-arg BASE_IMAGE=$@ --target esmf_full -t "liambindle/bmi:esmf-$@" 
	docker build . --build-arg BASE_IMAGE=$@ --target netcdf -t "liambindle/bmi:netcdf-$@" 

.PHONY: all esmf-mpi-variants

esmf-mpi-variants: esmf_slim-openmpi-3.0.4 esmf_slim-openmpi-3.1.4 esmf_slim-openmpi-4.0.1 esmf_slim-mpich-3.1.4 esmf_slim-mpich-3.2.1 esmf_slim-mpich-3.3.1 esmf_slim-mvapich-2.2 esmf_slim-mvapich-2.3.1

all: ubuntu centos alpine gcc8.3 gcc8.4 gcc9.3 gcc10.2 esmf-mpi-variants