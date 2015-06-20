FROM alpine:3.2

# Install runtime dependencies and download rtfd.
RUN echo nameserver 8.8.8.8 >> /etc/resolv.conf && \
    echo nameserver 8.8.4.4 >> /etc/resolv.conf && \
    apk add --update \
      git \
      wget \
      ca-certificates \
      python \
      libxslt \
      expect \
    && wget -nv --no-check-certificate \
      -O- https://bootstrap.pypa.io/get-pip.py | python \
    && git clone https://github.com/rtfd/readthedocs.org.git \
    && cd readthedocs.org \
    && git checkout 8fc71e5f16 \
    && rm -rf .git/ \
    && apk del \
      git \
      wget \
      ca-certificates \
    && rm -rf /var/cache/apk/*

WORKDIR readthedocs.org

# Install readthedocs.
RUN echo nameserver 8.8.8.8 >> /etc/resolv.conf && \
    echo nameserver 8.8.4.4 >> /etc/resolv.conf && \
    apk add --update \
      git \
      gcc \
      musl-dev \
      python-dev \
      zlib-dev \
      libxslt-dev \
      libxml2-dev \
    && pip install --upgrade pip \
    && pip install \
      cython \
      gunicorn \
    && pip install -r requirements.txt \
    && apk del \
      git \
      gcc \
      musl-dev \
      python-dev \
      zlib-dev \
      libxslt-dev \
      libxml2-dev \
    && rm -rf /root/.cache/ \
    && rm -rf /var/cache/apk/*

# Create sandboxed user.
RUN adduser -D -H -g "" django && \
    chown -R django:django /readthedocs.org && \
    chmod -R 0770 /readthedocs.org

USER django

WORKDIR readthedocs

COPY settings/docker.py settings/docker.py
COPY migrate.exp migrate.exp

RUN echo "import docker" > settings/__init__.py

# Collect the static files so that the can be served.
RUN ./manage.py collectstatic --noinput

ENV DJANGO_SETTINGS_MODULE settings.docker
ENV DJANGO_USER root
ENV DJANGO_PASS pass

EXPOSE 8000

ENTRYPOINT ./migrate.exp $DJANGO_USER $DJANGO_PASS && \
            gunicorn wsgi:application \
            --name readthedocs \
            --bind 0.0.0.0:8000 \
            --workers 3 \
            --log-level=info
