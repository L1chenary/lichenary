import os
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash, send_from_directory, jsonify, session
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, login_user, logout_user, login_required, UserMixin, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import cloudinary
import cloudinary.uploader
import cloudinary.api

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Configurare aplicație
app = Flask(__name__)
app.secret_key = 'lichena-foarte-secret-key'

# Configurare DB SQLite
db_url = os.environ.get("DATABASE_URL")
if db_url:
    app.config['SQLALCHEMY_DATABASE_URI'] = db_url.replace("postgres://", "postgresql://")
else:
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///lichenary.db'

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
cloudinary.config(
    cloud_name=os.getenv('CLOUDINARY_CLOUD_NAME'),
    api_key=os.getenv('CLOUDINARY_API_KEY'),
    api_secret=os.getenv('CLOUDINARY_API_SECRET'),
    secure=True
)

# Configurare folder upload
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
    is_approved = db.Column(db.Boolean, default=False)

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

# Model Observation
class Observation(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    image_filename = db.Column(db.Text, nullable=False)
    date_time = db.Column(db.DateTime, nullable=False)
    location = db.Column(db.String(300), nullable=False)
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    species = db.Column(db.String(150))
    pollution_level = db.Column(db.Integer)
    is_approved = db.Column(db.Boolean, default=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    user = db.relationship('User')

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

def create_tables_and_admin():
    db.create_all()
    admin = User.query.filter_by(username='admin').first()
    if not admin:
        admin = User(username='admin', email='admin@example.com', is_approved=True)
        db.session.add(admin)
        admin_password = os.getenv("ADMIN_PASSWORD", "parola123")  # fallback dacă nu există
        admin.set_password(admin_password)
    db.session.commit()
    print("Admin created or updated!")

if os.environ.get("RENDER"):
    with app.app_context():
        create_tables_and_admin()

# Routes
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

@app.route('/contact', methods=['GET', 'POST'])
def contact():
    if request.method == 'POST':
        name = request.form.get('nume')
        sender_email = request.form.get('email')
        message = request.form.get('mesaj')

        try:
            send_contact_email(name, sender_email, message)
            flash('Message sent successfully! Thank you.', 'success')
        except Exception as e:
            print(f"Email send failed: {e}")
            flash('There was an error sending your message. Please try again later.', 'error')

        return redirect(url_for('contact'))

    return render_template('contact.html')

# Subpages
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

# Register
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username').strip()
        email = request.form.get('email').strip()
        password = request.form.get('password')
        confirm_password = request.form.get('confirm_password')

        if not username or not email or not password or not confirm_password:
            flash('Please complete all fields.', 'error')
            return redirect(url_for('register'))

        if password != confirm_password:
            flash('Passwords do not match.', 'error')
            return redirect(url_for('register'))

        if User.query.filter((User.username == username) | (User.email == email)).first():
            flash('Username or email already used.', 'error')
            return redirect(url_for('register'))

        new_user = User(username=username, email=email)
        new_user.set_password(password)
        db.session.add(new_user)
        db.session.commit()

        flash('Registration successful! Your account will be approved soon.')
        return redirect(url_for('login'))

    return render_template('register.html')

# Login
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username').strip()
        password = request.form.get('password')
        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password):
            if not user.is_approved:
                flash('Your account is not approved yet.', 'error')
                return redirect(url_for('login'))
            login_user(user)
            flash(f'Welcome, {username}!')
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid username or password.', 'error')
            return redirect(url_for('login'))
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out.')
    return redirect(url_for('home'))

@app.route('/dashboard')
@login_required
def dashboard():
    return render_template('dashboard.html')

from cloudinary.uploader import upload

@app.route('/upload', methods=['GET', 'POST'])
@login_required
def upload_observation():
    if request.method == 'POST':
        if 'photo' not in request.files:
            flash('No photo selected.', 'error')
            return redirect(request.url)

        photo = request.files['photo']
        if not photo.filename:
            flash('No photo selected.', 'error')
            return redirect(request.url)

        # Upload imaginea pe Cloudinary
        result = upload(photo)
        image_url = result['secure_url']  # link-ul imaginii de pe Cloudinary

        # Preia datele din formular
        date_time_str = request.form.get('date_time')
        location = request.form.get('location').strip()
        latitude = request.form.get('latitude')
        longitude = request.form.get('longitude')
        species = request.form.get('species').strip() if request.form.get('species') else None
        pollution_level_str = request.form.get('pollution_level')

        # Validări date
        if not date_time_str or not location or not latitude or not longitude:
            flash('Please fill in all required fields.', 'error')
            return redirect(request.url)

        try:
            date_time = datetime.strptime(date_time_str, "%Y-%m-%dT%H:%M")
            latitude = float(latitude)
            longitude = float(longitude)
        except ValueError:
            flash('Invalid date or coordinates.', 'error')
            return redirect(request.url)

        pollution_level = None
        if pollution_level_str:
            try:
                pollution_level = int(pollution_level_str)
                if pollution_level < 1 or pollution_level > 10:
                    raise ValueError()
            except ValueError:
                flash('Pollution level must be a number between 1 and 10.', 'error')
                return redirect(request.url)

        # Creează observația cu link-ul imaginii din Cloudinary
        obs = Observation(
            image_filename=image_url,
            date_time=date_time,
            location=location,
            latitude=latitude,
            longitude=longitude,
            species=species,
            pollution_level=pollution_level,
            user_id=current_user.id,
            is_approved=False
        )

        db.session.add(obs)
        db.session.commit()

        flash('Observation uploaded successfully. Thank you!')
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
             'location': obs.location,
            'image_filename': obs.image_filename  # ✅ adăugat aici
        }
        for obs in observations
    ]
    return jsonify(data)

# Admin routes
@app.route('/admin/users')
@login_required
def admin_users():
    if current_user.username != 'admin':
        flash('Access denied.', 'error')
        return redirect(url_for('dashboard'))

    unapproved_users = User.query.filter_by(is_approved=False).all()
    approved_users = User.query.filter(User.is_approved == True, User.username != 'admin').all()

    return render_template('admin_users.html', users=unapproved_users, approved_users=approved_users)

@app.route('/admin/users/disapprove/<int:user_id>', methods=['POST'])
@login_required
def disapprove_user(user_id):
    if current_user.username != 'admin':
        flash('Access denied.', 'error')
        return redirect(url_for('dashboard'))

    user = User.query.get(user_id)
    if user:
        user.is_approved = False
        db.session.commit()
        flash(f'User {user.username} disapproved.')
    else:
        flash('User not found.', 'error')
    return redirect(url_for('admin_users'))

@app.route('/admin/users/approve/<int:user_id>', methods=['POST'])
@login_required
def approve_user(user_id):
    if current_user.username != 'admin':
        flash('Access denied.', 'error')
        return redirect(url_for('dashboard'))
    user = User.query.get(user_id)
    if user:
        user.is_approved = True
        db.session.commit()
        flash(f'User {user.username} approved.')
    else:
        flash('User not found.', 'error')
    return redirect(url_for('admin_users'))

@app.route('/admin/observations')
@login_required
def admin_observations():
    if current_user.username != 'admin':
        flash('Access denied.', 'error')
        return redirect(url_for('dashboard'))
    observations = Observation.query.filter_by(is_approved=False).order_by(Observation.date_time.desc()).all()
    return render_template('admin_observations.html', observations=observations)

@app.route('/admin/observations/approved')
@login_required
def admin_approved_observations():
    if current_user.username != 'admin':
        flash('Access denied.', 'error')
        return redirect(url_for('dashboard'))
    observations = Observation.query.filter_by(is_approved=True).order_by(Observation.date_time.desc()).all()
    return render_template('admin_approved_observations.html', observations=observations)

@app.route('/admin/observations/approve/<int:obs_id>', methods=['POST'])
@login_required
def approve_observation(obs_id):
    if current_user.username != 'admin':
        flash('Access denied.', 'error')
        return redirect(url_for('dashboard'))
    observation = Observation.query.get(obs_id)
    if observation:
        observation.is_approved = True
        db.session.commit()
        flash('Observation approved.')
    else:
        flash('Observation not found.', 'error')
    return redirect(url_for('admin_observations'))

@app.route('/admin/observations/<int:obs_id>/edit', methods=['GET', 'POST'])
@login_required
def edit_observation(obs_id):
    if current_user.username != 'admin':
        flash('Access denied.', 'error')
        return redirect(url_for('dashboard'))

    observation = Observation.query.get_or_404(obs_id)

    if request.method == 'POST':
        date_time_str = request.form.get('date_time')
        location = request.form.get('location').strip()
        latitude = request.form.get('latitude')
        longitude = request.form.get('longitude')
        species = request.form.get('species').strip()
        pollution_level_str = request.form.get('pollution_level')

        if not date_time_str or not location or not latitude or not longitude:
            flash('All fields are required.', 'error')
            return redirect(request.url)

        try:
            date_time = datetime.strptime(date_time_str, "%Y-%m-%dT%H:%M")
            latitude = float(latitude)
            longitude = float(longitude)
        except ValueError:
            flash('Invalid data.', 'error')
            return redirect(request.url)

        pollution_level = None
        if pollution_level_str:
            try:
                pollution_level = int(pollution_level_str)
                if pollution_level < 1 or pollution_level > 10:
                    raise ValueError()
            except ValueError:
                flash('Pollution level must be 1-10.', 'error')
                return redirect(request.url)

        observation.date_time = date_time
        observation.location = location
        observation.latitude = latitude
        observation.longitude = longitude
        observation.species = species
        observation.pollution_level = pollution_level

        db.session.commit()
        flash('Observation updated.')
        return redirect(url_for('admin_observations'))

    return render_template('admin_edit_observation.html', observation=observation)

@app.route('/admin/observations/disapprove/<int:obs_id>', methods=['POST'])
@login_required
def disapprove_observation(obs_id):
    if current_user.username != 'admin':
        flash('Access denied.', 'error')
        return redirect(url_for('dashboard'))

    obs = Observation.query.get_or_404(obs_id)
    obs.is_approved = False
    db.session.commit()
    flash('Observation disapproved.', 'success')
    return redirect(url_for('admin_approved_observations'))
@app.route('/admin/observations/delete/<int:obs_id>', methods=['POST'])
@login_required
def delete_observation(obs_id):
    if current_user.username != 'admin':
        flash('Access denied.', 'error')
        return redirect(url_for('dashboard'))

    observation = Observation.query.get_or_404(obs_id)
    db.session.delete(observation)
    db.session.commit()
    flash('Observation deleted.', 'success')
    return redirect(url_for('admin_observations'))

# ↓ Add this above if __name__ == '__main__':
def send_contact_email(name, sender_email, message):
    recipient_email = "lichenary@gmail.com"

    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = recipient_email
    msg['Subject'] = f"New message from {name} via Lichenary contact form"

    body = f"Name: {name}\nEmail: {sender_email}\n\nMessage:\n{message}"
    msg.attach(MIMEText(body, 'plain'))

    smtp_server = "smtp.gmail.com"
    smtp_port = 587
    your_gmail = "lichenary@gmail.com"
    your_password = os.getenv("EMAIL_APP_PASSWORD")

    with smtplib.SMTP(smtp_server, smtp_port) as server:
        server.starttls()
        server.login(your_gmail, your_password)
        server.send_message(msg)


if __name__ == '__main__':
    with app.app_context():
        create_tables_and_admin()
    app.run(debug=True)

