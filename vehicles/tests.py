import requests
response = requests.get("https://www.riverlong.com")
print(response.status_code)