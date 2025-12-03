FROM python:3.11-slim-bullseye

RUN apt update && apt install -y tesseract-ocr

RUN useradd -m -s /bin/bash curlylab
USER curlylab

WORKDIR /app

COPY requirements.txt .

RUN python -m venv venv && . venv/bin/activate && \
    pip install --prefer-binary -r requirements.txt

COPY rabbitmq_consumer.py .
COPY consists_check_service.py .

ENTRYPOINT ["/app/venv/bin/python", "rabbitmq_consumer.py"]
