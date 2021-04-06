# Arguments
ARG BASE_IMAGE

ARG ALPINE_VERSION=3.13
ARG UBUNTU_VERSION=20.04
ARG CENTOS_VERSION=8
ARG GCC_VERSION=8.3

# Base layers

FROM alpine:${ALPINE_VERSION} AS alpine-base
ENV APK_PACKAGES="cmake git make tar gzip unzip bzip2 xz patch curl python3 gcc g++ gfortran bash linux-headers"
RUN apk add --no-cache ${APK_PACKAGES}

FROM ubuntu:${UBUNTU_VERSION} AS ubuntu-base
ENV APT_PACKAGES="build-essential gfortran git ca-certificates python3 make tar gzip unzip bzip2 xz-utils patch curl"
RUN apt-get update && \
    apt-get install --no-install-recommends -y ${APT_PACKAGES} && \
    rm -rf /var/lib/apt/lists/*

FROM centos:${CENTOS_VERSION} AS centos-base
ENV DNF_PACKAGES="gcc-toolset-9-gcc gcc-toolset-9-gcc-c++ gcc-toolset-9-gcc-gfortran git python3 make tar gzip unzip bzip2 xz patch curl"
RUN dnf -y install ${DNF_PACKAGES} && \
    dnf clean all
ENV PATH=/opt/rh/gcc-toolset-9/root/usr/bin:$PATH

FROM gcc:${GCC_VERSION} AS gcc-base
ENV APT_PACKAGES="git ca-certificates python3 make tar gzip unzip bzip2 xz-utils patch curl"
RUN apt-get update && \
    apt-get install --no-install-recommends -y ${APT_PACKAGES} && \
    rm -rf /var/lib/apt/lists/*


# Noop layer

FROM ${BASE_IMAGE}-base as base
RUN touch /tmp/noop


# Spack layers
FROM base as spack
RUN cd /opt && \
    git clone https://github.com/spack/spack.git

# Extra utils
FROM spack as spack-with-utils
ARG SPACK_UTILS_SPEC="cmake"
RUN . /opt/spack/share/spack/setup-env.sh && \
    spack install -y ${SPACK_UTILS_SPEC} && \
    spack clean -a

# NetCDF-C and NetCDF-Fortran
FROM spack-with-utils as netcdf
ENV SPACK_PACKAGES="netcdf-c netcdf-fortran"
RUN . /opt/spack/share/spack/setup-env.sh && \
    spack install -y ${SPACK_PACKAGES} && \
    spack clean -a

# ESMF
FROM spack-with-utils as esmf_full
RUN . /opt/spack/share/spack/setup-env.sh && \
    spack install -y esmf && \
    spack clean -a

FROM spack-with-utils as esmf_custom
ARG SPACK_ESMF_SPEC="esmf"
RUN . /opt/spack/share/spack/setup-env.sh && \
    spack install -y ${SPACK_ESMF_SPEC} && \
    spack clean -a


# All image to join prior images (so build is concurrent)
FROM alpine:latest AS all
COPY --from=spack /tmp/noop /tmp/
COPY --from=netcdf /tmp/noop /tmp/
COPY --from=esmf_full /tmp/noop /tmp/