from bs4 import BeautifulSoup
import re

def extract_users(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    all_users = []
    admins = []
    # Extract Authorized Administrators
    authorized_admins = re.findall(r'Authorized Administrators:(.+?)<b>Authorized Users:</b>', html_content, re.DOTALL)
    admins_list = [x.strip().split(' ')[0] for x in authorized_admins[0].split('\n') if x.strip() and 'password' not in x]
    # Extract Authorized Users
    authorized_users = re.findall(r'<b>Authorized Users:</b>\s*((?:\w+\s*)+)', html_content, re.DOTALL)
    users_list = [x.strip() for x in authorized_users[0].split('\n') if x.strip()]
    users_list = users_list + admins_list
    users_list.sort()
    admins_list.sort()
    return users_list, admins_list

# Example usage
with open('readme.aspx', 'r') as file:
    aspx_content = file.read()

all_authorized_users, admin_users = extract_users(aspx_content)

print("All Authorized Users:", all_authorized_users)
print("Admins:", admin_users)
