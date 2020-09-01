# Created by Nikita Ashok and Jake Polacek on 08/04/2020
# create HHVM version arg
ARG HHVM_IMAGE=hhvm/hhvm
ARG HHVM_VERSION=4.36.0

# inherit from HHVM base image
FROM ${HHVM_IMAGE}:${HHVM_VERSION}

RUN groupadd -r -g 999 sanitizer && useradd -r -m -u 999 --shell /bin/false -g sanitizer sanitizer

COPY install-composer.sh .
RUN chmod +x ./install-composer.sh && ./install-composer.sh

WORKDIR /html-sanitizer/
RUN chown sanitizer:sanitizer /html-sanitizer 
USER sanitizer

COPY --chown=sanitizer:sanitizer src/ /html-sanitizer/src/
COPY --chown=sanitizer:sanitizer tests/ /html-sanitizer/tests/
COPY --chown=sanitizer:sanitizer .hhconfig composer.json composer.lock hh_autoload.json /html-sanitizer/
RUN php /composer.phar install
