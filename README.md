# Autobid-Deployed

A comprehensive automated bidding system for vehicle auctions built with **Django**.  
Users can set bidding parameters, and the system automatically places bids on their behalf. Includes user management, vehicle catalog, auction tracking, and a powerful admin dashboard.

**Frontend uses Bootstrap 5 + Vanilla JS** (no JavaScript frameworks or libraries like React, Vue, or Alpine).

---

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Database](#database)
- [Configuration](#configuration)
- [Usage](#usage)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

**Autobid-Deployed** is a full-stack Django web application designed specifically for vehicle auctions. It allows users to browse vehicles, set maximum bid limits, and let the system handle automated bidding during live auctions. The platform includes secure user authentication, a clean responsive interface, and a comprehensive admin panel.

## ✨ Features

- **Automated Bidding System** — Set bid limits and let the system place bids automatically
- **Vehicle Catalog** — Browse and filter vehicles by multiple criteria
- **Auction Tracking** — Monitor active, completed, and won auctions
- **User Management** — Secure registration, login, and profile management
- **Admin Dashboard** — Full control via Django Admin (manage auctions, users, vehicles, and reports)
- **Export Functionality** — Export auction data and reports
- **Database Backups** — Automated daily backup scripts included

## 🛠 Tech Stack

### Backend
- **Framework**: Django 5.0.7
- **Language**: Python 3.8+
- **Database**: SQLite3 (development) / MySQL / PostgreSQL (production)
- **Admin Panel**: Django Admin (customized)
- **Key Packages**:
  - Django REST Framework (API)
  - Django CKEditor (rich text editing)
  - Django Crispy Forms (with Bootstrap 5)
  - Celery (background & async tasks)
  - django-import-export, Python-docx, WeasyPrint, ReportLab

### Frontend
- **HTML5**
- **Styling**: Bootstrap 5 + custom CSS
- **JavaScript**: Vanilla JS only (no JS frameworks or libraries)
- **Forms**: Django Crispy Forms with Bootstrap styling

### DevOps & Deployment
- **Web Server**: wfastcgi (for IIS on Windows)
- **Storage**: AWS S3 (via boto3)
- **Utilities**: Arrow, Humanize, Rich

## 📦 Installation

### Prerequisites
- Python 3.8+
- pip

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/martinmbogo-254/Autobid-Deployed.git
   cd Autobid-Deployed
