# Created by Nikita Ashok and Jake Polacek on 08/04/2020
# create HHVM version arg
ARG HHVM_IMAGE=hhvm/hhvm
ARG HHVM_VERSION=4.36.0

# inherit from HHVM base image
FROM ${HHVM_IMAGE}:${HHVM_VERSION}

RUN groupadd -r -g 999 sanitizer && useradd -r -m -u 999 --shell /bin/false -g sanitizer sanitizer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e5325b19b381bfd88ce90a5ddb7823406b2a38cff6bb704b0acc289a09c8128d4a8ce2bbafcd1fcbdc38666422fe2806') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=bin
RUN php -r "unlink('composer-setup.php');"

WORKDIR /html-sanitizer/
RUN chown sanitizer:sanitizer /html-sanitizer 
USER sanitizer

COPY --chown=sanitizer:sanitizer src/ /html-sanitizer/src/
COPY --chown=sanitizer:sanitizer tests/ /html-sanitizer/tests/
COPY --chown=sanitizer:sanitizer .hhconfig composer.json composer.lock hh_autoload.json /html-sanitizer/
RUN php /bin/composer.phar install
