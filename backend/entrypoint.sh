#!/bin/sh
set -e

echo "Waiting for database..."
until python manage.py check --database default >/dev/null 2>&1; do
  echo "Database is not ready yet. Waiting..."
  sleep 2
done

echo "Applying database migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput

if [ -n "${DJANGO_SUPERUSER_USERNAME}" ] && \
   [ -n "${DJANGO_SUPERUSER_EMAIL}" ] && \
   [ -n "${DJANGO_SUPERUSER_PASSWORD}" ]; then
  echo "Ensuring Django superuser exists..."
  python manage.py shell <<EOF
import os
from django.contrib.auth import get_user_model

User = get_user_model()
username = os.environ.get("DJANGO_SUPERUSER_USERNAME")
email = os.environ.get("DJANGO_SUPERUSER_EMAIL")
password = os.environ.get("DJANGO_SUPERUSER_PASSWORD")

if username and email and password:
    if not User.objects.filter(username=username).exists():
        User.objects.create_superuser(username=username, email=email, password=password)
EOF
fi

echo "Starting Gunicorn WSGI server..."
exec gunicorn conduit.wsgi:application --bind 0.0.0.0:8000