#!/bin/bash

set -e

flutter test --coverage
lcov --list coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html
cd coverage/html && static-server -o
