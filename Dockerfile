FROM python:3.12-slim AS build

WORKDIR /docs

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN mkdocs build --strict --site-dir /site

FROM nginx:alpine

COPY --from=build /site /usr/share/nginx/html
EXPOSE 80