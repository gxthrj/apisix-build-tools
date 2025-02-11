#!/usr/bin/env bash
set -euo pipefail
set -x

build_apisix_openresty_rpm() {
    yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo
    yum -y install gcc gcc-c++ patch wget git make sudo
    yum -y install openresty-openssl111-devel openresty-pcre-devel openresty-zlib-devel

    export_openresty_variables
    ./build-apisix-openresty.sh
}

build_apisix_openresty_deb() {
    DEBIAN_FRONTEND=noninteractive apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y sudo git libreadline-dev lsb-release libssl-dev perl build-essential
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends wget gnupg ca-certificates
    wget -O - https://openresty.org/package/pubkey.gpg | apt-key add -
    echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/openresty.list
    DEBIAN_FRONTEND=noninteractive apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y openresty-openssl111-dev openresty-pcre-dev openresty-zlib-dev

    export_openresty_variables
    ./build-apisix-openresty.sh
}

export_openresty_variables() {
    export openssl_prefix=/usr/local/openresty/openssl111
    export zlib_prefix=/usr/local/openresty/zlib
    export pcre_prefix=/usr/local/openresty/pcre

    export cc_opt="-DNGX_LUA_ABORT_AT_PANIC -I${zlib_prefix}/include -I${pcre_prefix}/include -I${openssl_prefix}/include"
    export ld_opt="-L${zlib_prefix}/lib -L${pcre_prefix}/lib -L${openssl_prefix}/lib -Wl,-rpath,${zlib_prefix}/lib:${pcre_prefix}/lib:${openssl_prefix}/lib"
}

case_opt=$1

case ${case_opt} in
build_apisix_openresty_rpm)
    build_apisix_openresty_rpm
    ;;
build_apisix_openresty_deb)
    build_apisix_openresty_deb
    ;;
esac
