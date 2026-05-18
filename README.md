# 🚀 Antigravity Profile Manager

[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/Shell-Bash-orange.svg)](https://www.gnu.org/software/bash/)
[![Python](https://img.shields.io/badge/Python-3.x-yellow.svg)](https://www.python.org)

An elegant, lightweight, and robust profile management utility for **Antigravity** (a premium VS Code-based text editor). 

This tool allows you to create, manage, and run **multiple fully-isolated Antigravity profiles concurrently** (at the exact same time) with distinct user data, extensions, and custom-badged icons.

---

## 🌟 Key Features

* 🚀 **Concurrent Instances:** Open multiple profiles in separate windows simultaneously without session or extension collision.
* 🎨 **Dynamic Badged Icons:** Auto-generates high-definition badged icons (e.g. Profile A with a blue Teal badge, Profile B with a coral Orange badge) using an inline Python PIL processor.
* 🖥️ **Interactive Zenity GUI:** A beautiful, responsive list-picker dialog to launch existing profiles or easily create brand-new isolated profiles on the fly.
* 📦 **Universal Linux Installer:** A single, smart installer script compatible with all major package managers (`dnf`, `apt`, `pacman`).
* 🔗 **Smart Settings Sync:** Automatically symlinks your default editor configurations (`settings.json`, keybindings, snippets) so you don't start from scratch, while keeping extensions and accounts strictly isolated.

---

## 📸 How it Works visually

```
+-------------------------------------------------------------+
|               Antigravity Profile Switcher                 |
+-------------------------------------------------------------+
|  Choose an Antigravity profile to launch.                   |
|  Isolated profiles can run at the same time!                |
|                                                             |
|  +-------------------------------------------------------+  |
|  | Profile Name          | Profile Type                  |  |
|  +-------------------------------------------------------+  |
|  | + Create New Profile  | [Info]                        |  |
|  | Default               | Legacy Profile (Shared)       |  |
|  | Profile A             | Isolated Profile (Concurrent) |  |
|  | Profile B             | Isolated Profile (Concurrent) |  |
|  | FaresCEO              | Legacy Profile (Shared)       |  |
|  +-------------------------------------------------------+  |
|                                                             |
|                   [ Cancel ]     [ OK ]                     |
+-------------------------------------------------------------+
```

---

## 🛠️ One-Click Installation

Open your terminal and run the following command to clone and install the Profile Manager instantly:

```bash
git clone https://github.com/jlildev/antigravity-profile-manager.git
cd antigravity-profile-manager
bash install.sh
```

### What the installer does:
1. Detects your OS and automatically installs missing dependencies (`zenity`, `python3-pillow`, `notify-send`).
2. Generates dynamic high-res badged icons (`antigravity-a.png` and `antigravity-b.png`) under your `~/.local/share/icons/` folder.
3. Sets up the configuration paths and symlinks settings from your default profile.
4. Registers local `.desktop` launcher shortcuts in `~/.local/share/applications/` so they appear instantly in your GNOME/KDE/XFCE application menus.
5. Copies the `antigravity-switcher` executable to `~/.local/bin/` so you can launch the GUI picker from anywhere.

---

## 📖 Usage Guide

You can launch and use the profiles in three distinct ways:

### 1. From your Application Menu (GUI)
Search for **"Antigravity"** in your system applications:
* Click **Antigravity (Profile A)** to open your isolated Profile A.
* Click **Antigravity (Profile B)** to open your isolated Profile B.
* Click **Antigravity Switcher** to open the Zenity list selector.

Both profiles can be active **at the same time** and will appear as separate items in your desktop dock/taskbar!

### 2. From the Command Line (CLI)
You can launch the Zenity switcher GUI by running:
```bash
antigravity-switcher
```

You can also launch a specific profile directly from the terminal:
* **Profile A:**
  ```bash
  antigravity --user-data-dir ~/.config/antigravity-profile-A --extensions-dir ~/.antigravity-ext-A
  ```
* **Profile B:**
  ```bash
  antigravity --user-data-dir ~/.config/antigravity-profile-B --extensions-dir ~/.antigravity-ext-B
  ```

---

## 📂 Directories & File Structure

Here is how the manager isolates your profiles in the Linux user space:

| Component | Profile A Path | Profile B Path | Description |
| :--- | :--- | :--- | :--- |
| **User Data** | `~/.config/antigravity-profile-A` | `~/.config/antigravity-profile-B` | Caches, history, state, and sessions. |
| **Extensions** | `~/.antigravity-ext-A` | `~/.antigravity-ext-B` | Separated workspace plugins/extensions. |
| **Custom Icon** | `~/.local/share/icons/antigravity-a.png` | `~/.local/share/icons/antigravity-b.png` | Dynamically badged high-res PNG icons. |
| **Launcher** | `~/.local/share/applications/antigravity-a.desktop` | `~/.local/share/applications/antigravity-b.desktop` | Desktop entries to integrate with the OS. |

---

## 🔒 Security & Privacy

This utility runs entirely in **user space**. It does not require root/sudo access during everyday execution. `sudo` is only requested by the installer script to download the standard dependency packages (`zenity`, `python3-pillow`) if they are missing from your system.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
