from app import app, db, create_tables_and_admin

with app.app_context():
    create_tables_and_admin()
    print("Tabelele au fost create.")
