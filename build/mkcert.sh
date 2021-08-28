#!/usr/bin/env bash
#
# mkcert has to be installed to use this script.
# for more information and installation instructions,
# read https://github.com/FiloSottile/mkcert
#

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

CERT_PATH=${SCRIPTPATH}/nginx

mkcert \
    -cert-file ${CERT_PATH}/app.crt \
    -key-file ${CERT_PATH}/app.key \
    dhbw.test \
    *.dhbw.test \
    localhost \
    127.0.0.1 \
    ::1

cat "$(mkcert -CAROOT)/rootCA.pem">> ${CERT_PATH}/app.crt
