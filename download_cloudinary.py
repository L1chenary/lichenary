import os
import cloudinary
import cloudinary.api
import requests

# ==============================
# 1. CONFIGUREAZĂ DATELE CLOUDINARY
# ==============================
cloudinary.config(
    cloud_name="dkaff7r7k",  # numele tău de cloud (NU SCHIMBA)
    api_key="815677694551182",
    api_secret="YiTaw6y8xfD2rLJXzEJdjIPAvXI",
    secure=True
)

# ==============================
# 2. FOLDER DE BACKUP
# ==============================
output_dir = "cloudinary_backup"
os.makedirs(output_dir, exist_ok=True)

# ==============================
# 3. DESCĂRCĂ TOATE IMAGINILE
# ==============================
print("📥 Încep descărcarea tuturor imaginilor din Cloudinary...")

next_cursor = None
count = 0

while True:
    # cerem lista de imagini
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