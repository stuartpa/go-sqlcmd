# Example:
# docker run -it microsoft/go-mssqltools ./sqlcmd --help
#

FROM debian:stable-slim AS build-env
ARG BUILD_DATE
ARG CLI_VERSION
ARG MSSQL_TOOLS_PIPELINE_RUN_NUMBER

LABEL maintainer="Microsoft" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Microsoft" \
      org.label-schema.name="MSSQL Tools CLI" \
      org.label-schema.version=$CLI_VERSION \
      org.label-schema.license="TODO: e.g. https://aka.ms/eula-azdata-en" \
      org.label-schema.description="The MSSQL Tools CLI." \
      org.label-schema.url="https://github.com/microsoft/go-sqlcmd" \
      org.label-schema.usage="https://docs.microsoft.com/sql/tools/sqlcmd-utility" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.docker.cmd="docker run -it microsoft/go-mssqltools:$CLI_VERSION"

RUN apt-get update
RUN apt-get install -y locales

# Locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV CLI_VERSION=$CLI_VERSION
ENV MSSQL_TOOLS_PIPELINE_RUN_NUMBER=$MSSQL_TOOLS_PIPELINE_RUN_NUMBER

WORKDIR /
COPY ./sqlcmd sqlcmd

WORKDIR /

CMD bash
