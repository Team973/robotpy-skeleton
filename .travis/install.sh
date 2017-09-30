#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then

    case "${TOXENV}" in
        py36)
            brew install python3
            pip3 install pyfrc coverage
            ;;
    esac
else
    pip3 install pyfrc coverage
fi
