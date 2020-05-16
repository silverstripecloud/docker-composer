FROM silverstripecloud/base:7-apache

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        bash \
        coreutils \
        git \
        make \
        mercurial \
        openssh-client \
        patch \
        subversion \
        tini \
        unzip \
        zip

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.8.6
ENV COMPOSER_INSTALLER_URL https://raw.githubusercontent.com/composer/getcomposer.org/cb19f2aa3aeaa2006c0cd69a7ef011eb31463067/web/installer
ENV COMPOSER_INSTALLER_HASH 48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5

RUN printf "# composer php cli ini settings\n\
date.timezone=UTC\n\
memory_limit=-1\n\
" > $PHP_INI_DIR/php-cli.ini \
    && curl --silent --fail --location --retry 3 --output /tmp/installer.php --url ${COMPOSER_INSTALLER_URL} \
    && php -r " \
        \$signature = '${COMPOSER_INSTALLER_HASH}'; \
        \$hash = hash('sha384', file_get_contents('/tmp/installer.php')); \
        if (!hash_equals(\$signature, \$hash)) { \
          unlink('/tmp/installer.php'); \
          echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
          exit(1); \
        }" \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    && composer --ansi --version --no-interaction \
    && rm -f /tmp/installer.php \
    && find /tmp -type d -exec chmod -v 1777 {} + \
    && composer require \
        silverstripe/recipe-core

CMD ["composer"]