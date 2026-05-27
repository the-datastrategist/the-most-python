FROM python:3.11-slim

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    DBT_PROFILES_DIR=/app/profiles \
    GOOGLE_APPLICATION_CREDENTIALS=/secrets/gcp-key.json

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

COPY dbt_project.yml .
COPY models/ models/
COPY profiles/ profiles/

ENTRYPOINT ["dbt"]
CMD ["build"]
