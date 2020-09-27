FROM silverstripecloud/base:7.4-cli-alpine3.11
LABEL maintainer="SilverStripe Cloud <dev@silverstripecloud.com>"

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp

RUN apk add --no-cache \
        bash \
        coreutils \
        git \
        libzip-dev \
        make \
        mercurial \
        openssh-client \
        patch \
        subversion \
        tini \
        unzip \
        zip \
    && docker-php-ext-install -j "$(nproc)" \
        zip \
    && printf "# composer php cli ini settings\n\
date.timezone=UTC\n\
memory_limit=-1\n\
" > "$PHP_INI_DIR/php-cli.ini" \
    && curl --silent --fail --location --retry 3 --output /tmp/installer.php --url https://raw.githubusercontent.com/composer/getcomposer.org/99312bc6306564ac1f0ad2c6207c129b3aff58d6/web/installer \
    && php -r " \
        \$signature = 'e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a'; \
        \$hash = hash('sha384', file_get_contents('/tmp/installer.php')); \
        if (!hash_equals(\$signature, \$hash)) { \
          unlink('/tmp/installer.php'); \
          echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
          exit(1); \
        }" \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=1.8.6 \
    && composer --ansi --version --no-interaction \
    && rm -f /tmp/installer.php \
    && find /tmp -type d -exec chmod -v 1777 {} + \
    && composer require \
        silverstripe/recipe-core

WORKDIR /app
CMD ["composer"]