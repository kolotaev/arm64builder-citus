#!/bin/bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && (pwd -W 2> /dev/null || pwd))

while getopts p:c:a:d:v:h: flag
do
    case "${flag}" in
        p) POSTGRES_MAJOR_VERSION=${OPTARG};;
        c) CITUS_VERSION=${OPTARG};;
        a) BUILD_ARCH=${OPTARG};;
        d) DEBIAN_VERSION=${OPTARG};;
    esac
done

pg_major=${POSTGRES_MAJOR_VERSION:-'14'}
citus_version=${CITUS_VERSION:-'10.2.5'}
build_arch=${BUILD_ARCH:-'arm64'}
debian_version=${DEBIAN_VERSION:-'11'}

image_name=citus-${citus_version}-pgsql-${pg_major}-builder
work_dir=~/citus-build/${pg_major}


echo "Builing for Postgres ${pg_major} Citus ${citus_version} on ${build_arch} Debian-${debian_version}"

buildah bud -t ${image_name} -f citus.Containerfile \
    --arch ${build_arch} \
    --build-arg POSTGRES_MAJOR_VERSION=${pg_major} \
    --build-arg CITUS_VERSION=${citus_version} \
    --build-arg BUILD_ARCH=${build_arch} \
    --build-arg DEBIAN_IMAGE_VERSION=${debian_version} \
    ${SCRIPT_DIR}

mkdir -p ${work_dir}
podman run --rm -v ${work_dir}:/var/output:z ${image_name}
ls -alh ${work_dir}
