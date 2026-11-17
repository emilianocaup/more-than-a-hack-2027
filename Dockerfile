FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements-mojarra.txt .
RUN pip install --no-cache-dir -r requirements-mojarra.txt

COPY evaluation/ ./evaluation/
COPY games.py ./
COPY starter/ ./starter/

CMD ["python", "evaluation/run_evaluation.py"]
