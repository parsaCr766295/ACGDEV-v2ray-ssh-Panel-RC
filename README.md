# Rocket Panel 2026 (ACGDEV Edition) 🚀

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-2026.1.0-green.svg)
![Status](https://img.shields.io/badge/status-Stable-success.svg)

**Rocket Panel 2026** is a next-generation management panel for V2Ray and SSH services, built with modern technologies to provide speed, security, and scalability. Designed to be a superior alternative to existing panels like X-UI or Rocket SSH.

---

## ✨ Key Features

### 🖥️ Modern Dashboard
- **Real-time Monitoring:** Live CPU, RAM, and connection stats.
- **Responsive Design:** Fully compatible with Desktop, Tablet, and Mobile.
- **Dark Mode:** Built-in dark theme for better usability.

### 🔐 Advanced Security
- **JWT Authentication:** Secure API access with JSON Web Tokens.
- **Role-Based Access Control (RBAC):** Granular permissions for Admins and Users.
- **SSH Key Management:** Secure server connections using private keys.

### ⚡ High Performance
- **Backend:** Powered by **FastAPI (Python 3.11)** for asynchronous performance.
- **Frontend:** Built with **React 18 + Vite** for lightning-fast loading.
- **Database:** Optimized **SQLite/PostgreSQL** support via SQLModel.

### 🛠️ Server Management
- **Multi-Server Support:** Manage unlimited SSH/V2Ray servers from a single panel.
- **One-Click Connection Test:** Verify server status instantly.
- **Auto-Deployment:** Docker-based installation ensuring consistency.

---

## 🚀 Installation

### Automated Install (Recommended)
Run the following command on your **Ubuntu 20.04+** server:

```bash
curl -fsSL https://raw.githubusercontent.com/parsaCr766295/ACGDEV-v2ray-ssh-Panel-RC/main/scripts/install.sh | sudo bash
```

### Manual Installation (Docker)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/parsaCr766295/ACGDEV-v2ray-ssh-Panel-RC.git
   cd ACGDEV-v2ray-ssh-Panel-RC
   ```

2. **Start services:**
   ```bash
   docker compose up -d --build
   ```

3. **Access the panel:**
   - **URL:** `http://YOUR_SERVER_IP:3000`
   - **Default Admin:** `admin`
   - **Default Password:** `admin` (Change immediately after login!)

---

## 🏗️ Architecture

- **Backend:** Python, FastAPI, SQLAlchemy, Paramiko
- **Frontend:** TypeScript, React, TailwindCSS, Recharts
- **Infrastructure:** Docker, Docker Compose, Nginx (Optional)

---

## 🤝 Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for details.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
**Developed by ACGDEV Team © 2026**
