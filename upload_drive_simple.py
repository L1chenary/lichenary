from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import os
import csv

# ===========================
# CONFIGURAȚI AICI
# ===========================
local_folder = "cloudinary_backup"  # folderul cu imaginile descărcate
csv_output = "google_drive_links.csv"

# ===========================
# AUTENTIFICARE
# ===========================
gauth = GoogleAuth()
gauth.LocalWebserverAuth()  # se va deschide browser pentru login
drive = GoogleDrive(gauth)

# ===========================
# CREARE FOLDER NOU PE DRIVE
# ===========================
folder_name = "LichenaryBackup"
folder_metadata = {'title': folder_name, 'mimeType': 'application/vnd.google-apps.folder'}
folder = drive.CreateFile(folder_metadata)
folder.Upload()
folder_id = folder['id']
print(f"Folder creat cu ID: {folder_id}")

# ===========================
# UPLOAD ȘI CSV
# ===========================
with open(csv_output, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["filename", "link"])  # header CSV

    for filename in os.listdir(local_folder):
        local_path = os.path.join(local_folder, filename)
        if os.path.isfile(local_path):
            gfile = drive.CreateFile({"parents": [{"id": folder_id}], "title": filename})
            gfile.SetContentFile(local_path)
            gfile.Upload()
            # link public
            gfile.InsertPermission({
                "type": "anyone",
                "value": "anyone",
                "role": "reader"
            })
            link = f"https://drive.google.com/uc?id={gfile['id']}"
            writer.writerow([filename, link])
            print(f"✅ Uploaded: {filename}")

print(f"\n🎉 Toate imaginile au fost urcate. CSV creat: {csv_output}")
