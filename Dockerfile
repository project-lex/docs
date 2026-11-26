FROM python:3.12-slim AS dev

WORKDIR /docs

# Debian's plantuml package is from 2020 (no `!theme`), so use the upstream jar
ARG PLANTUML_VERSION=1.2026.10
RUN apt-get update \
 && apt-get install -y --no-install-recommends default-jre-headless graphviz curl ca-certificates \
 && curl -fsSL -o /opt/plantuml.jar \
      https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar \
 && printf '#!/bin/sh\nexec java -Djava.awt.headless=true -jar /opt/plantuml.jar "$@"\n' > /usr/local/bin/plantuml \
 && chmod +x /usr/local/bin/plantuml \
 && apt-get purge -y curl && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000
CMD ["zensical", "serve", "--dev-addr=0.0.0.0:8000"]

FROM python:3.12-slim AS build

WORKDIR /docs

# Debian's plantuml package is from 2020 (no `!theme`), so use the upstream jar
ARG PLANTUML_VERSION=1.2026.10
RUN apt-get update \
 && apt-get install -y --no-install-recommends default-jre-headless graphviz curl ca-certificates \
 && curl -fsSL -o /opt/plantuml.jar \
      https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar \
 && printf '#!/bin/sh\nexec java -Djava.awt.headless=true -jar /opt/plantuml.jar "$@"\n' > /usr/local/bin/plantuml \
 && chmod +x /usr/local/bin/plantuml \
 && apt-get purge -y curl && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
# plantuml_markdown only logs diagram errors, so fail the build on them explicitly
RUN zensical build --clean --strict > /tmp/build.log 2>&1 || { cat /tmp/build.log; exit 1; }; \
    cat /tmp/build.log; \
    ! grep -q "Error in" /tmp/build.log

FROM nginx:alpine

COPY --from=build /docs/site /usr/share/nginx/html
EXPOSE 80