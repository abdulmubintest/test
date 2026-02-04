"""
Views for test1 application.
"""
from django.http import JsonResponse
from django.views import View
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
import os
import datetime


class HomePageView(View):
    """Home page view for the application."""
    
    def get(self, request):
        """Return a simple HTML home page."""
        from django.http import HttpResponse
        return HttpResponse(
            '<html><head><title>VPS Test Server</title></head>' +
            '<body style="font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px;">' +
            '<h1>🚀 VPS Django Test Server</h1>' +
            '<p>This server is running successfully!</p>' +
            '<h2>Available Endpoints:</h2>' +
            '<ul>' +
            '<li><a href="/health/">/health/</a> - Health check endpoint</li>' +
            '<li><a href="/api/status/">/api/status/</a> - Server status API</li>' +
            '<li><a href="/admin/">/admin/</a> - Django admin</li>' +
            '</ul>' +
            '<h2>Server Info:</h2>' +
            '<p>Django Version: 4.2+</p>' +
            '<p>Status: <span style="color: green;">Operational</span></p>' +
            '</body></html>'
        )


class HealthCheckView(View):
    """Health check endpoint for VPS monitoring."""
    
    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)
    
    def get(self, request):
        """
        Return health status of the application.
        Used by load balancers and monitoring systems.
        """
        return JsonResponse({
            'status': 'healthy',
            'service': 'Vps Web Server',
            'timestamp': datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'version': '1.0.0',
            'environment': {
                'debug': os.environ.get('DEBUG', 'Unknown'),
                'python_version': os.sys.version,
            }
        })


class ServerInfoView(View):
    """Server information endpoint."""
    
    @method_decorator(csrf_exempt)
    def dispatch(self, *args, **kwargs):
        return super().dispatch(*args, **kwargs)
    
    def get(self, request):
        """Return basic server information."""
        return JsonResponse({
            'message': 'VPS Web Server is running successfully',
            'server_time': datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'django_version': '4.2+',
            'status': 'operational'
        })
