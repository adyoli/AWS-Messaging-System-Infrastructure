import os
import sys
import requests
import time

def check_service_health(url: str, retries: int = 5, delay: int = 5):
    """
    Sends a request to the HTTP service to check its health.
    Retries a few times before failing.
    """
    print(f"--- Starting Health Check for URL: {url} ---")
    for i in range(retries):
        try:
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                print(f"✅ Health check PASSED. Service is responding.")
                print(f"Response: {response.text.strip()}")
                return True
            else:
                print(f"Attempt {i+1}/{retries}: ⚠️ Health check FAILED with status code {response.status_code}.")

        except requests.RequestException as e:
            print(f"Attempt {i+1}/{retries}: ⚠️ Health check FAILED with exception: {e}")

        if i < retries - 1:
            print(f"Retrying in {delay} seconds...")
            time.sleep(delay)

    print(f"❌ Health check FAILED after {retries} attempts.")
    return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python health_check.py <URL>")
        sys.exit(1)

    service_url = sys.argv[1]
    
    if not check_service_health(service_url):
        sys.exit(1)