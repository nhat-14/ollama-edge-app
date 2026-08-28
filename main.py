import datetime
import time
import subprocess
import os
from ollama import Client

result = subprocess.run(["uname", "-r"], capture_output=True, text=True)
kernel_version = result.stdout.strip()

result = subprocess.run(["cat", "/sys/class/dmi/id/product_name"], capture_output=True, text=True)
edge_product_name = result.stdout.strip()

print(f"kernel_version: {kernel_version}")
print(f"edge_product_name: {edge_product_name}")

host = os.environ.get("OLLAMA_HOST", "http://ollama:11434")
model = os.environ.get("OLLAMA_MODEL", "tinyllama")

client = Client(host)

response = client.chat(
    model=model,
    messages=[{"role": "user", "content": "Hello from the edge device"}],
)
print(response["message"]["content"])


print("Starting the program. If stopping, please press Ctrl+C")


try:
    while True:
        now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"Now: {now}")
        time.sleep(10)

except KeyboardInterrupt:
    print("\nStopped")
