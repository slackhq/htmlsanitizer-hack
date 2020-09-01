#!/usr/bin/env bash
# Created by Nikita Ashok and Jake Polacek on 08/04/2020
set -e

hhvm --version

docker build -t first-sanitizer-test:latest .
docker run --rm first-sanitizer-test:latest vendor/bin/hacktest tests
