import os
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, send_from_directory, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, logout_user, login_required, UserMixin, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename

# Configurare aplicație
app = Flask(__name__)

app.secret_key = 'lichena-foarte-secret-key'

# Configurare DB SQLite
db_url = os.environ.get("DATABASE_URL")
if db_url:
    # Dacă ești pe Render și ai DATABASE_URL, folosește PostgreSQL
    app.config['SQLALCHEMY_DATABASE_URI'] = db_url.replace("postgres://", "postgresql://")
else:
    # Altfel, local rămâi cu SQLite
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///lichenary.db'

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Configurare folder de upload
UPLOAD_FOLDER = os.path.join(app.root_path, 'static', 'uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

db = SQLAlchemy(app)

# Flask-Login setup
login_manager = LoginManager()
login_manager.login_view = 'login'
login_manager.init_app(app)

# Model User
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), unique=True, nullable=False)
    email = db.Column(db.String(150), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    is_approved = db.Column(db.Boolean, default=False)  # Nou

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

# Model Observation
class Observation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    image_filename = db.Column(db.String(300), nullable=False)
    date_time = db.Column(db.DateTime, nullable=False)
    location = db.Column(db.String(300), nullable=False)
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    species = db.Column(db.String(150))
    pollution_level = db.Column(db.Integer)  # 1-10
    is_approved = db.Column(db.Boolean, default=False)  # Nou
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user = db.relationship('User')

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Definim funcția create_tables_and_admin aici, înainte să o apelăm
def create_tables_and_admin():
    db.create_all()
    admin = User.query.filter_by(username='admin').first()
    if not admin:
        admin = User(username='admin', email='admin@example.com', is_approved=True)
        admin.set_password('parola123')  # Schimbă parola după ce intri prima dată!
        db.session.add(admin)
        db.session.commit()
        print("Admin creat!")

# Creează tabelele o singură dată când aplicația pornește pe Render
if os.environ.get("RENDER"):
    with app.app_context():
        create_tables_and_admin()

# Rute (la fel ca înainte, dar login verifică acum is_approved)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/despre')
def despre():
    return render_template('despre.html')

@app.route('/participa')
def participa():
    return render_template('participa.html')

@app.route('/galerie')
def galerie():
    return render_template('galerie.html')

@app.route('/harta')
def harta():
    return render_template('harta.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

# Rute noi pentru subcapitolele specificate

@app.route('/despre/proiect_si_rol')
def despre_proiect_si_rol():
    return render_template('despre_proiect_si_rol.html')

@app.route('/despre/poluare_atmosferica')
def despre_pol_atmosferica():
    return render_template('despre_pol_atmosferica.html')

@app.route('/despre/licheni')
def despre_licheni():
    return render_template('despre_licheni.html')

@app.route('/despre/echipa')
def despre_echipa():
    return render_template('despre_echipa.html')

@app.route('/despre/timeline')
def despre_timeline():
    return render_template('despre_timeline.html')

@app.route('/despre/resurse')
def despre_resurse():
    return render_template('despre_resurse.html')

@app.route('/despre/parteneri')
def despre_parteneri():
    return render_template('despre_parteneri.html')

@app.route('/participa/voluntariezi')
def participa_voluntariez():
    return render_template('participa_voluntariez.html')

@app.route('/participa/ambasador')
def participa_ambasador():
    return render_template('participa_ambasador.html')

# Înregistrare
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username').strip()
        email = request.form.get('email').strip()
        password = request.form.get('password')
        confirm_password = request.form.get('confirm_password')

        if not username or not email or not password or not confirm_password:
            flash('Completează toate câmpurile.', 'error')
            return redirect(url_for('register'))

        if password != confirm_password:
            flash('Parolele nu coincid.', 'error')
            return redirect(url_for('register'))

        if User.query.filter((User.username == username) | (User.email == email)).first():
            flash('Username sau email deja folosit.', 'error')
            return redirect(url_for('register'))

        new_user = User(username=username, email=email)
        new_user.set_password(password)
        # implicit new_user.is_approved = False
        db.session.add(new_user)
        db.session.commit()

        flash('Înregistrare reușită! Contul tău va fi aprobat în curând de un moderator.')
        return redirect(url_for('login'))

    return render_template('register.html')

# Login cu verificare is_approved
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username').strip()
        password = request.form.get('password')
        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password):
            if not user.is_approved:
                flash('Contul tău nu este aprobat încă. Te rugăm să aștepți aprobarea moderatorului.', 'error')
                return redirect(url_for('login'))
            login_user(user)
            flash(f'Bine ai venit, {username}!')
            return redirect(url_for('dashboard'))
        else:
            flash('Username sau parolă greșită.', 'error')
            return redirect(url_for('login'))
    return render_template('login.html')

# Logout
@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Te-ai deconectat.')
    return redirect(url_for('home'))

# Dashboard
@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html')

# Restul rutelor (upload_observation, view_observations, uploads, api_observations) - le păstrezi la fel

@app.route('/upload', methods=['GET', 'POST'])
@login_required
def upload_observation():
    if request.method == 'POST':
        if 'photo' not in request.files:
            flash('Nu a fost selectată nicio poză.', 'error')
            return redirect(request.url)

        photo = request.files['photo']
        date_time_str = request.form.get('date_time')
        location = request.form.get('location').strip()
        latitude = request.form.get('latitude')
        longitude = request.form.get('longitude')
        species = request.form.get('species').strip() if request.form.get('species') else None
        pollution_level_str = request.form.get('pollution_level')

        if not photo.filename or not date_time_str or not location or not latitude or not longitude:
            flash('Completează toate câmpurile, inclusiv coordonatele.', 'error')
            return redirect(request.url)

        pollution_level = None
        if pollution_level_str:
            try:
                pollution_level = int(pollution_level_str)
                if pollution_level < 1 or pollution_level > 10:
                    raise ValueError()
            except ValueError:
                flash('Nivelul de poluare trebuie să fie un număr între 1 și 10.', 'error')
                return redirect(request.url)

        filename = secure_filename(photo.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)

        if os.path.exists(filepath):
            name, ext = os.path.splitext(filename)
            filename = f"{name}_{int(datetime.utcnow().timestamp())}{ext}"
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)

        photo.save(filepath)

        try:
            date_time = datetime.strptime(date_time_str, "%Y-%m-%dT%H:%M")
        except ValueError:
            flash('Formatul datei este incorect.', 'error')
            return redirect(request.url)

        obs = Observation(
            image_filename=filename,
            date_time=date_time,
            location=location,
            latitude=float(latitude),
            longitude=float(longitude),
            species=species if species else None,
            pollution_level=pollution_level,
            user_id=current_user.id,
            is_approved=False  # implicit la upload
        )
        db.session.add(obs)
        db.session.commit()

        flash('Observația a fost încărcată cu succes. Mulțumim!')
        return redirect(url_for('view_observations'))

    return render_template('upload_observation.html')

@app.route('/observations')
@login_required
def view_observations():
    observations = Observation.query.filter_by(user_id=current_user.id).order_by(Observation.date_time.desc()).all()
    return render_template('observations.html', observations=observations)

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/api/observations')
def api_observations():
    observations = Observation.query.filter(
        Observation.latitude != None,
        Observation.longitude != None,
        Observation.pollution_level != None,
        Observation.is_approved == True
    ).all()

    data = [
        {
            'id': obs.id,
            'latitude': obs.latitude,
            'longitude': obs.longitude,
            'pollution_level': obs.pollution_level,
            'species': obs.species,
            'date_time': obs.date_time.strftime('%Y-%m-%d %H:%M'),
            'location': obs.location
        }
        for obs in observations
    ]
    return jsonify(data)

# Admin - vizualizare utilizatori neaprobati și aprobare
@app.route('/admin/users')
@login_required
def admin_users():
    if current_user.username != 'admin':
        flash('Nu ai permisiunea să accesezi această pagină.', 'error')
        return redirect(url_for('dashboard'))
    users = User.query.filter_by(is_approved=False).all()
    return render_template('admin_users.html', users=users)

@app.route('/admin/users/approve/<int:user_id>', methods=['POST'])
@login_required
def approve_user(user_id):
    if current_user.username != 'admin':
        flash('Nu ai permisiunea să faci această acțiune.', 'error')
        return redirect(url_for('dashboard'))
    user = User.query.get(user_id)
    if user:
        user.is_approved = True
        db.session.commit()
        flash(f'User {user.username} aprobat cu succes.')
    else:
        flash('User inexistent.', 'error')
    return redirect(url_for('admin_users'))

# Admin - vizualizare observații neaprobate și aprobare
@app.route('/admin/observations')
@login_required
def admin_observations():
    if current_user.username != 'admin':
        flash('Nu ai permisiunea să accesezi această pagină.', 'error')
        return redirect(url_for('dashboard'))
    observations = Observation.query.filter_by(is_approved=False).order_by(Observation.date_time.desc()).all()
    return render_template('admin_observations.html', observations=observations)

# Admin - vizualizare observații aprobate
@app.route('/admin/observations/approved')
@login_required
def admin_approved_observations():
    if current_user.username != 'admin':
        flash('Nu ai permisiunea să accesezi această pagină.', 'error')
        return redirect(url_for('dashboard'))
    observations = Observation.query.filter_by(is_approved=True).order_by(Observation.date_time.desc()).all()
    return render_template('admin_approved_observations.html', observations=observations)

@app.route('/admin/observations/approve/<int:obs_id>', methods=['POST'])
@login_required
def approve_observation(obs_id):
    if current_user.username != 'admin':
        flash('Nu ai permisiunea să faci această acțiune.', 'error')
        return redirect(url_for('dashboard'))
    observation = Observation.query.get(obs_id)
    if observation:
        observation.is_approved = True
        db.session.commit()
        flash('Observație aprobată cu succes.')
    else:
        flash('Observație inexistentă.', 'error')
    return redirect(url_for('admin_observations'))

if __name__ == '__main__':
    with app.app_context():
        create_tables_and_admin()
    app.run(debug=True)

