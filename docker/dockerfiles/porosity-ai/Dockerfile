FROM python:3.11-slim-bullseye

RUN apt update && apt install -y tesseract-ocr

RUN useradd -m -s /bin/bash curlylab
USER curlylab

WORKDIR /app
RUN mkdir -p models

COPY requirements.txt .

RUN python -m venv venv && . venv/bin/activate && \
    pip install --prefer-binary -r requirements.txt

COPY rabbitmq_consumer.py .
COPY main.py .
COPY models_loader.py .
COPY models/__init__.py models/
COPY models/swa_convnext.pt models/

ENTRYPOINT ["/app/venv/bin/python", "rabbitmq_consumer.py"]
