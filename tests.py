# Try adding this at the top of your script to verify the module is available
import sys
print(sys.path)  # This will show you where Python is looking for modules

import requests
print(requests.__version__)  # This will show the version if installed