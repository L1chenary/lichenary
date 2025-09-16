import os
import requests
import cloudinary
import cloudinary.api

# ==============================
# 1. CONFIGUREAZĂ DATELE CLOUDINARY (cont nou)
# ==============================
cloudinary.config(
    cloud_name="dr8rvsmlz",  # cloud_name din contul nou
    api_key="675464513995391",        # API Key din contul nou
    api_secret="c58ROfs5nZAQCPmlD03aDpvBWwo",  # API Secret din contul nou
    secure=True
)

# ==============================
# 2. FOLDER DE BACKUP
# ==============================
output_dir = "cloudinary_backup_nou"
os.makedirs(output_dir, exist_ok=True)

# ==============================
# 3. DESCĂRCĂ TOATE IMAGINILE
# ==============================
print("📥 Încep descărcarea tuturor imaginilor din noul cont Cloudinary...")

next_cursor = None
count = 0

while True:
    response = cloudinary.api.resources(max_results=500, next_cursor=next_cursor)
    resources = response['resources']

    for res in resources:
        url = res['secure_url']
        public_id = res['public_id'].replace("/", "_")
        ext = res['format']
        filename = f"{public_id}.{ext}"
        path = os.path.join(output_dir, filename)

        # descarcă fișierul
        r = requests.get(url)
        with open(path, "wb") as f:
            f.write(r.content)

        count += 1
        print(f"✅ Salvat: {filename}")

    next_cursor = response.get("next_cursor")
    if not next_cursor:
        break

print(f"\n🎉 Am descărcat {count} imagini în folderul '{output_dir}'!")
