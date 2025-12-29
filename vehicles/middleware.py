# middleware.py
from django.utils.deprecation import MiddlewareMixin
from .models import AdminActionLog
from django.contrib.contenttypes.models import ContentType
import json

class AdminActionLogMiddleware(MiddlewareMixin):
    def process_request(self, request):
        # Store the request for later use
        request._admin_log_data = {}
        
    def process_response(self, request, response):
        # Check if we're in the admin area and user is authenticated
        if request.path.startswith('/admin/') and hasattr(request, 'user') and request.user.is_authenticated:
            # Exclude media and static URLs
            if not any(x in request.path for x in ['/media/', '/static/']):
                self._log_admin_action(request, response)
        return response
    
    def _log_admin_action(self, request, response):
        # Determine action type based on request
        action_type = 'VIEW'
        if request.method == 'POST':
            if 'delete' in request.path:
                action_type = 'DELETE'
            elif '/add/' in request.path:
                action_type = 'CREATE'
            elif '/change/' in request.path:
                action_type = 'UPDATE'
        
        # Handle login/logout
        if 'login' in request.path and request.method == 'POST' and response.status_code in [200, 302]:
            action_type = 'LOGIN'
        elif 'logout' in request.path:
            action_type = 'LOGOUT'

        # Extract model information when possible
        content_type = None
        object_id = None
        object_repr = ''
        
        # Attempt to extract content type and object info from URL
        # This is a simplified version and might need customization
        path_parts = request.path.strip('/').split('/')
        if len(path_parts) > 2 and path_parts[0] == 'admin':
            try:
                app_label, model_name = path_parts[1], path_parts[2]
                content_type = ContentType.objects.get(app_label=app_label, model=model_name)
                if len(path_parts) > 3 and path_parts[3].isdigit():
                    object_id = path_parts[3]
                    # Get a string representation if possible
                    try:
                        model_class = content_type.model_class()
                        if model_class and object_id:
                            obj = model_class.objects.get(pk=object_id)
                            object_repr = str(obj)
                    except:
                        pass
            except:
                pass
        
        # Create log entry
        AdminActionLog.objects.create(
            user=request.user,
            action_type=action_type,
            ip_address=self._get_client_ip(request),
            content_type=content_type,
            object_id=object_id,
            object_repr=object_repr,
            change_message=self._get_change_message(request),
            user_agent=request.META.get('HTTP_USER_AGENT', '')
        )
    
    def _get_client_ip(self, request):
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip
    
    def _get_change_message(self, request):
        # Attempt to extract form data, sanitize as needed
        try:
            post_data = request.POST.copy()
            # Remove sensitive fields like passwords
            for key in list(post_data.keys()):
                if 'password' in key.lower() or 'token' in key.lower():
                    post_data[key] = '********'
            return json.dumps(dict(post_data))
        except:
            return ''