#!/usr/bin/env python3

import os
import runpod
import requests

def handler(job):
    base_url = "http://localhost:11434"
    payload = job["input"]["payload"]
    method_name = job["input"]["method_name"]
    payload["stream"] = False  # Disable streaming as required
    resp = requests.post(
        url=f"{base_url}/api/{method_name}/",
        headers={"Content-Type": "application/json"},
        json=payload,
    )
    resp.encoding = "utf-8"
    return resp.json()

if __name__ == "__main__":
    # Start the RunPod serverless function
    runpod.serverless.start({"handler": handler})
