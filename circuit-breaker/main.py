import base64
import json
import os
import functions_framework
from googleapiclient import discovery

@functions_framework.cloud_event
def stop_billing(cloud_event):
    # 1. Safely extract the project name dynamically
    attributes = cloud_event.data.get("message", {}).get("attributes", {})
    project_id = attributes.get("projectId") or os.environ.get("GCP_PROJECT")
    
    if not project_id:
        print("Error: Could not determine Project ID.")
        return
        
    project_name = f"projects/{project_id}"

    # 2. Decode the Pub/Sub alert payload
    payload = cloud_event.data["message"]["data"]
    budget = json.loads(base64.b64decode(payload).decode("utf-8"))

    cost = budget.get("costAmount", 0)
    limit = budget.get("budgetAmount", 0)

    # 3. Check if the budget threshold has actually been crossed
    if cost <= limit:
        print(f"OK — cost {cost} <= budget {limit}, no action.")
        return

    print(f"Alert! Cost ({cost}) exceeded budget limit ({limit}). Initiating shutdown...")

    # 4. Initialize the Google Cloud Billing API client
    billing = discovery.build("cloudbilling", "v1")
    projects = billing.projects()
    
    # 5. Direct Hard-Stop (No read check required)
    try:
        projects.updateBillingInfo(
            name=project_name, 
            body={"billingAccountName": ""}  # Detaches the billing link immediately
        ).execute()
        print("Billing DISABLED successfully.")
    except Exception as e:
        print(f"Failed to disable billing: {e}")