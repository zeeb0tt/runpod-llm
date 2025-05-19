#!/usr/bin/env python3

import runpod
import requests

def handler(job):
    try:
        resp = requests.post(
            url=f"http://localhost:11434{job['input']['path']}",
            headers={"Authorization":"Bearer not-used-but-required","Content-Type":"application/json"},
            json=job["input"]["payload"],
        )
        resp.raise_for_status()
        resp.encoding = "utf-8"
        return resp.json()
    except requests.exceptions.RequestException as e:
        return {"error": str(e), "status_code": getattr(e.response, 'status_code', 500)}

if __name__ == "__main__":
    # Start the RunPod serverless function
    runpod.serverless.start({"handler": handler})
