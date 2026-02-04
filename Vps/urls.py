"""
URL configuration for Vps project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
"""
from django.contrib import admin
from django.urls import path, include
from test1 import views

urlpatterns = [
    path('', views.HomePageView.as_view(), name='home'),
    path('admin/', admin.site.urls),
    # Health check endpoints for VPS monitoring
    path('health/', views.HealthCheckView.as_view(), name='health_check'),
    path('api/status/', views.ServerInfoView.as_view(), name='server_status'),
]
