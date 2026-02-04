# Procfile for deployment platforms (Heroku, Railway, Render, etc.)

web: gunicorn Vps.wsgi:application --bind 0.0.0.0:$PORT
release: python manage.py migrate --noinput
