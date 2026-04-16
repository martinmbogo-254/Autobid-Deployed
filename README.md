# Autobid-Deployed

A comprehensive automated bidding system for vehicle auctions with real-time bidding capabilities, user management, and auction tracking.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Database](#database)
- [Configuration](#configuration)
- [Usage](#usage)
- [Development](#development)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## 🎯 Overview

**Autobid-Deployed** is a full-stack auction bidding platform designed specifically for vehicle auctions. It automates the bidding process, allowing users to set bidding parameters and let the system handle real-time bids. The platform features comprehensive user authentication, vehicle catalog management, and detailed auction tracking.

## ✨ Features

- **Automated Bidding System** - Set bid limits and let the system automatically place bids
- **Real-time Updates** - Live auction status and bid notifications
- **User Management** - Secure authentication and user profile management
- **Vehicle Catalog** - Browse and filter vehicles by multiple criteria
- **Auction Tracking** - Monitor active, completed, and won auctions
- **Admin Dashboard** - Manage auctions, users, and system settings
- **Export Functionality** - Export auction data and reports
- **Database Backups** - Automated daily backup scripts

## 🛠 Tech Stack

### Backend
- **Framework:** Django 5.0.7
- **Language:** Python
- **Database:** SQLite3 / MySQL / PostgreSQL
- **Admin Panel:** Django Admin with enhanced features
- **Rich Features:** 
  - Django CKEditor for rich text editing
  - Django REST Framework for API
  - Crispy Forms with Bootstrap5/Tailwind styling
  - Celery for async tasks

### Frontend
- **Markup:** HTML5
- **Styling:** CSS3 + Tailwind CSS
- **JavaScript:** Vanilla JS + Node.js tooling
- **CSS Processing:** PostCSS + Autoprefixer

### DevOps & Deployment
- **Web Server:** wfastcgi (IIS integration)
- **Storage:** AWS S3 (via boto3)
- **Environment:** Supports Windows deployment (web.config)

### Additional Libraries
- **Document Generation:** Python-docx, WeasyPrint, ReportLab
- **Data Import/Export:** django-import-export, tablib
- **Utilities:** Arrow, Humanize, Rich

## 📦 Installation

### Prerequisites
- Python 3.8+
- Node.js 14+ (for frontend tooling)
- SQLite3, MySQL, or PostgreSQL
- pip and npm package managers

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/martinmbogo-254/Autobid-Deployed.git
   cd Autobid-Deployed
   ```

2. **Create a virtual environment (recommended)**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Install Node.js dependencies**
   ```bash
   npm install
   ```

5. **Configure environment variables**
   - Copy `.env.example` to `.env`
   - Update database credentials, secret keys, and AWS settings

6. **Run database migrations**
   ```bash
   python manage.py migrate
   ```

7. **Create superuser**
   ```bash
   python manage.py createsuperuser
   ```


9. **Start development server**
   ```bash
   python manage.py runserver
   ```

10. **Access the application**
    - Application: `http://localhost:8000`
    - Admin Panel: `http://localhost:8000/admin`

## 📁 Project Structure

```
Autobid-Deployed/
├── auctions/                          # Auction app
│   ├── models.py                     # Auction data models
│   ├── views.py                      # Auction views
│   ├── templates/                    # Auction templates
│   └── migrations/                   # Database migrations
├── users/                             # User management app
│   ├── models.py                     # User models
│   ├── views.py                      # User views
│   └── templates/                    # User templates
├── vehicles/                          # Vehicle catalog app
│   ├── models.py                     # Vehicle models
│   ├── views.py                      # Vehicle views
│   └── templates/                    # Vehicle templates
├── templates/                         # Global templates
├── static/                            # Static files (CSS, JS, images)
├── media/                             # User-uploaded files
├── manage.py                          # Django management script
├── requirements.txt                   # Python dependencies
├── package.json                       # Node.js dependencies
├── web.config                         # IIS configuration
├── autobid.sql                        # Database schema
├── database.sql                       # Alternative database schema
├── Backup_project.bat                # Backup script
├── backup_db.bat                      # Database backup script
├── daily_db_backup.bat                # Daily automated backup
├── sitemap.xml                        # SEO sitemap
└── README.md                          # This file
```

## 🗄 Database

The project includes multiple database options:

- **SQLite3** (Development): Pre-configured, file-based
- **MySQL** (Production): Via mysqlclient
- **PostgreSQL** (Production): Via psycopg2-binary

### Database Files
- `autobid.sql` - Full schema and initial data
- `database.sql` - Alternative schema
- `db.sqlite3` - Development database
- `db - Copy-21.01.2026.sqlite3` - Backup database

### Database Backups
Automated backup scripts are included:
- `backup_db.bat` - Manual backup
- `daily_db_backup.bat` - Scheduled daily backup

## ⚙️ Configuration

### Environment Variables
Create a `.env` file in the project root:

```env
DEBUG=False
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1,yourdomain.com

### Django Settings
- Update `settings.py` with your configuration
- Configure static files and media directories
- Set up logging and error tracking

## 🚀 Usage

### For Users
1. Register a new account
2. Browse available vehicles in auctions
3. Set up bidding preferences
4. Let the system automatically bid on your behalf
5. Monitor auction progress in your dashboard
6. Manage won auctions and payments

### For Administrators
1. Access admin panel at `/admin`
2. Manage auctions and vehicle listings
3. Monitor user activity
4. Generate reports and exports
5. Configure system settings



## 🌐 Deployment

### Windows IIS Deployment
The project includes `web.config` for IIS deployment:

```bash
# Install wfastcgi
pip install wfastcgi

# Configure IIS handler mapping to wfastcgi
```

## 🔧 Troubleshooting

### Socket Issues
See `socket issue fixes.txt` for WebSocket configuration solutions.

### Database Connection
- Check database credentials in `.env`
- Verify database server is running
- Check firewall/network settings

### Static Files Not Loading
```bash
python manage.py collectstatic --clear
```

### Migration Issues
```bash
# Check migration status
python manage.py showmigrations

# Reset migrations (development only)
python manage.py migrate app_name zero
python manage.py migrate
```

## 📝 License

This project is open source and available under the ISC License.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📧 Support

For questions or issues, please create an issue on GitHub or contact the maintainer.

---

**Last Updated:** April 16, 2026  
**Repository:** [martinmbogo-254/Autobid-Deployed](https://github.com/martinmbogo-254/Autobid-Deployed)
