# VPS Django Test Server

A production-ready Django project configured for testing and deployment on a VPS.

## Features

- ✅ Production-ready Django configuration
- ✅ Environment variable management with `.env`
- ✅ Health check endpoints for server monitoring
- ✅ Docker support for containerized deployment
- ✅ Industry-standard project structure
- ✅ Security best practices

## Quick Start

### Prerequisites

- Python 3.10+
- pip or pip3
- Virtual environment (recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd test
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # or
   .\venv\Scripts\activate   # Windows
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Edit .env with your settings
   nano .env
   ```

5. **Run database migrations**
   ```bash
   python manage.py migrate
   ```

6. **Start the development server**
   ```bash
   python manage.py runserver
   ```

7. **Access the application**
   - Main site: http://localhost:8000
   - Health check: http://localhost:8000/health/
   - Server status: http://localhost:8000/api/status/

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRET_KEY` | Django secret key | Auto-generated |
| `DEBUG` | Debug mode | `True` |
| `ALLOWED_HOSTS` | Comma-separated host list | `localhost,127.0.0.1` |
| `DATABASE_URL` | Database connection string | `sqlite:///db.sqlite3` |
| `STATIC_URL` | Static files URL | `/static/` |
| `MEDIA_URL` | Media files URL | `/media/` |

## Health Check Endpoints

The application provides the following endpoints for server monitoring:

- `GET /health/` - Returns JSON with server health status
- `GET /api/status/` - Returns server information and operational status

Example response from `/health/`:
```json
{
    "status": "healthy",
    "service": "Vps Web Server",
    "timestamp": "2024-01-01T00:00:00Z",
    "version": "1.0.0"
}
```

## Deployment to VPS

### Option 1: Direct Deployment

1. **Connect to your VPS**
   ```bash
   ssh user@your-vps-ip
   ```

2. **Clone and setup**
   ```bash
   git clone <your-repo-url>
   cd test
   ```

3. **Configure production settings**
   ```bash
   cp .env.example .env
   # Edit .env with production values
   nano .env
   # Set DEBUG=False
   # Add your domain to ALLOWED_HOSTS
   ```

4. **Setup with Gunicorn**
   ```bash
   pip install gunicorn
   gunicorn Vps.wsgi:application --bind 0.0.0.0:8000
   ```

5. **Setup systemd service** (recommended)
   Create `/etc/systemd/system/gunicorn.service`:
   ```ini
   [Unit]
   Description=gunicorn daemon for Vps project
   After=network.target

   [Service]
   User=www-data
   Group=www-data
   WorkingDirectory=/path/to/test
   Environment="PATH=/path/to/test/venv/bin"
   ExecStart=/path/to/test/venv/bin/gunicorn \
           --workers 3 \
           --bind unix:/path/to/test/gunicorn.sock \
           Vps.wsgi:application

   [Install]
   WantedBy=multi-user.target
   ```

### Option 2: Docker Deployment

1. **Build and run with Docker**
   ```bash
   docker build -t vps-test-server .
   docker run -p 8000:8000 --env-file .env vps-test-server
   ```

2. **Using Docker Compose**
   ```bash
   docker-compose up -d
   ```

## Project Structure

```
test/
├── Vps/                 # Django project settings
│   ├── __init__.py
│   ├── settings.py     # Main settings (development)
│   ├── urls.py         # URL routing
│   ├── wsgi.py         # WSGI config
│   └── asgi.py         # ASGI config
├── test1/              # Django application
│   ├── __init__.py
│   ├── views.py        # Health check views
│   ├── apps.py
│   ├── admin.py
│   ├── models.py
│   └── tests.py
├── static/             # Static files (create if needed)
├── media/              # Uploaded files (create if needed)
├── templates/          # HTML templates (create if needed)
├── manage.py           # Django management script
├── requirements.txt    # Python dependencies
├── .env               # Environment variables (local)
├── .env.example       # Environment template
├── .gitignore         # Git ignore rules
├── Dockerfile         # Docker configuration
├── docker-compose.yml # Docker Compose config
└── README.md          # This file
```

## Testing

Run the test suite:
```bash
python manage.py test
```

## Security Checklist

- [ ] Change `SECRET_KEY` in production
- [ ] Set `DEBUG=False` in production
- [ ] Configure `ALLOWED_HOSTS` with your domain
- [ ] Use HTTPS in production
- [ ] Keep dependencies updated
- [ ] Review logging configuration

## License

This project is open source and available under the MIT License.
