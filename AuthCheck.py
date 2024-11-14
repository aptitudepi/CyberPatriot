from bs4 import BeautifulSoup
import re

def extract_users_and_services(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # Extract Authorized Administrators
    authorized_admins = re.findall(r'Authorized Administrators:(.+?)Authorized Users:', html_content, re.DOTALL)
    admins_list = [x.strip().split(' ')[0] for x in authorized_admins[0].split('\n') if x.strip() and 'password' not in x]
    
    # Extract Authorized Users
    authorized_users = re.findall(r'Authorized Users:\s*((?:\w+\s*)+)', html_content, re.DOTALL)
    users_list = [x.strip() for x in authorized_users[0].split('\n') if x.strip()]
    
    # Extract Critical Services
    critical_services = re.findall(r'Critical Services:\s*((?:\w+\s*)+)', html_content, re.DOTALL)
    services_list = [x.strip().lower() for x in critical_services[0].split('\n') if x.strip()]
    
    all_users = list(set(users_list + admins_list))
    all_users.sort()
    admins_list.sort()
    
    return all_users, admins_list, services_list

import re
import requests
from urllib.parse import unquote

# Read the README.desktop file
desktop_file_path = '~/Desktop/README.desktop'
with open(desktop_file_path, 'r') as file:
    desktop_content = file.read()

# Extract the URL using regex
url_match = re.search(r'Exec=x-www-browser "(.*?)"', desktop_content)
if url_match:
    url = unquote(url_match.group(1))
    print(f"Extracted URL: {url}")

    # Download the readme.aspx file
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for bad status codes

        # Save the content to readme.aspx
        with open('readme.aspx', 'w', encoding='utf-8') as file:
            file.write(response.text)
        print("readme.aspx has been successfully downloaded and saved.")

    except requests.RequestException as e:
        print(f"An error occurred while downloading the file: {e}")
else:
    print("URL not found in the README.desktop file.")

# Read the readme.aspx file
with open('readme.aspx', 'r') as file:
    aspx_content = file.read()

all_authorized_users, admin_users, critical_services = extract_users_and_services(aspx_content)

# Write all users to a file
with open('all_users.txt', 'w') as f:
    for user in all_authorized_users:
        f.write(f"{user}\n")

# Write admins to a file
with open('admin_users.txt', 'w') as f:
    for admin in admin_users:
        f.write(f"{admin}\n")

# Write critical services to a file
with open('critical_services.txt', 'w') as f:
    for service in critical_services:
        f.write(f"{service}\n")

print("User lists and critical services have been written to all_users.txt, admin_users.txt, and critical_services.txt")
