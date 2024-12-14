#!/bin/bash

# Based on https://stackoverflow.com/questions/69002453/how-to-build-openssl-for-m1-and-for-intel

if [[ $* == *-arch\ x86_64* ]] && ! [[ $* == *-arch\ arm64* ]]; then
    echo Forcing compilation with arm64
    cc -arch arm64 $@
else
    cc $@
fi
