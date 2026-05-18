#!/bin/bash

# ==========================================
# Antigravity Profile Manager Installer
# Safe, Cross-Distro, User-Space Setup
# ==========================================

set -e

# Target paths
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
CONFIG_DIR="$HOME/.config"
DEFAULT_USER_DIR="$CONFIG_DIR/Antigravity_Profile_Default/User"

echo "🚀 Starting Antigravity Profile Manager installation..."

# 1. Check and install dependencies
install_dependencies() {
    echo "🔍 Checking dependencies..."
    MISSING_DEPS=()
    
    if ! command -v zenity &>/dev/null; then
        MISSING_DEPS+=("zenity")
    fi
    
    if ! command -v python3 &>/dev/null; then
        MISSING_DEPS+=("python3")
    fi
    
    if ! python3 -c "from PIL import Image" &>/dev/null; then
        MISSING_DEPS+=("python3-pillow")
    fi

    if [ ${#MISSING_DEPS[@]} -eq 0 ]; then
        echo "✅ All dependencies are already installed!"
        return 0
    fi

    echo "⚠️ Missing dependencies: ${MISSING_DEPS[*]}"
    echo "🔄 Attempting to install missing dependencies..."
    
    # Detect Package Manager
    if command -v dnf &>/dev/null; then
        echo "📦 Detected Fedora/RHEL system (dnf)"
        sudo dnf install -y "${MISSING_DEPS[@]/python3-pillow/python3-pillow}"
    elif command -v apt-get &>/dev/null; then
        echo "📦 Detected Debian/Ubuntu system (apt)"
        sudo apt-get update
        sudo apt-get install -y "${MISSING_DEPS[@]/python3-pillow/python3-pil}"
    elif command -v pacman &>/dev/null; then
        echo "📦 Detected Arch Linux system (pacman)"
        sudo pacman -S --noconfirm "${MISSING_DEPS[@]/python3-pillow/python-pillow}"
    else
        echo "❌ Unsupported package manager. Please install the following manually: ${MISSING_DEPS[*]}"
        exit 1
    fi
}

install_dependencies

# Create necessary directories
mkdir -p "$BIN_DIR"
mkdir -p "$APP_DIR"
mkdir -p "$ICON_DIR"

# 2. Setup Profile directories and settings
echo "📂 Setting up isolated profiles..."
for p in A B; do
    P_DATA_DIR="$CONFIG_DIR/antigravity-profile-$p"
    P_EXT_DIR="$HOME/.antigravity-ext-$p"
    
    mkdir -p "$P_DATA_DIR/User"
    mkdir -p "$P_EXT_DIR"
    
    # Symlink settings from Default profile if they exist
    if [ -f "$DEFAULT_USER_DIR/settings.json" ]; then
        ln -sf "$DEFAULT_USER_DIR/settings.json" "$P_DATA_DIR/User/settings.json"
    fi
    if [ -f "$DEFAULT_USER_DIR/keybindings.json" ]; then
        ln -sf "$DEFAULT_USER_DIR/keybindings.json" "$P_DATA_DIR/User/keybindings.json"
    fi
    if [ -d "$DEFAULT_USER_DIR/snippets" ]; then
        ln -sfT "$DEFAULT_USER_DIR/snippets" "$P_DATA_DIR/User/snippets"
    fi
done

# 3. Generate beautiful badged icons using Python PIL
echo "🎨 Generating custom profile icons dynamically..."
python3 - <<EOF
import os
from PIL import Image, ImageDraw, ImageFont

# Candidate source paths for the base icon
candidates = [
    "/usr/share/pixmaps/antigravity.png",
    "/usr/share/pixmaps/vscode.png",
    "/usr/share/pixmaps/code.png",
    "/usr/share/icons/hicolor/1024x1024/apps/antigravity.png",
    "/usr/share/icons/hicolor/512x512/apps/antigravity.png",
    "/usr/share/icons/hicolor/scalable/apps/antigravity.svg"
]

source_icon = None
for path in candidates:
    if os.path.exists(path):
        source_icon = path
        break

if not source_icon:
    # Try searching for any png containing 'antigravity' or 'code'
    for root, dirs, files in os.walk('/usr/share/pixmaps'):
        for file in files:
            if 'antigravity' in file.lower() and file.endswith('.png'):
                source_icon = os.path.join(root, file)
                break
        if source_icon:
            break

def generate_icon(label, badge_color, border_color, output_path, source_path=None):
    if source_path and os.path.exists(source_path):
        im = Image.open(source_path).convert("RGBA")
        width, height = im.size
    else:
        # Create standard premium background if no base icon found
        width, height = 512, 512
        im = Image.new("RGBA", (width, height), (30, 41, 59, 255))
        draw = ImageDraw.Draw(im)
        font_path = "/usr/share/fonts/dejavu-sans-fonts/DejaVuSans-Bold.ttf"
        if not os.path.exists(font_path):
            font_path = None
        try:
            center_font = ImageFont.truetype(font_path, 200) if font_path else ImageFont.load_default()
            bbox = draw.textbbox((0, 0), "AG", font=center_font)
            w = bbox[2] - bbox[0]
            h = bbox[3] - bbox[1]
            draw.text(((width - w)/2 - bbox[0], (height - h)/2 - bbox[1]), "AG", fill=(241, 245, 249, 255), font=center_font)
        except Exception:
            pass

    draw = ImageDraw.Draw(im)
    radius = int(width * 0.14)
    center_x = int(width * 0.8)
    center_y = int(height * 0.8)
    border = int(radius * 0.1)
    
    # Outer white border
    draw.ellipse(
        [center_x - radius - border, center_y - radius - border, center_x + radius + border, center_y + radius + border],
        fill=border_color
    )
    
    # Inner colored circle
    draw.ellipse(
        [center_x - radius, center_y - radius, center_x + radius, center_y + radius],
        fill=badge_color
    )
    
    font_path = "/usr/share/fonts/dejavu-sans-fonts/DejaVuSans-Bold.ttf"
    if not os.path.exists(font_path):
        font_path = None
        
    font_size = int(radius * 1.3)
    try:
        font = ImageFont.truetype(font_path, font_size) if font_path else ImageFont.load_default()
        bbox = draw.textbbox((0, 0), label, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        text_x = center_x - text_width / 2 - bbox[0]
        text_y = center_y - text_height / 2 - bbox[1]
        draw.text((text_x, text_y), label, fill="white", font=font)
    except Exception:
        draw.text((center_x - 10, center_y - 10), label, fill="white")
        
    im.save(output_path, "PNG")

icon_a_path = os.path.expanduser("~/.local/share/icons/antigravity-a.png")
icon_b_path = os.path.expanduser("~/.local/share/icons/antigravity-b.png")

generate_icon("A", (14, 165, 233, 255), (255, 255, 255, 255), icon_a_path, source_icon)
generate_icon("B", (249, 115, 22, 255), (255, 255, 255, 255), icon_b_path, source_icon)
print("✅ Profile A and Profile B icons successfully generated!")
EOF

# 4. Install Switcher Script
echo "📝 Installing switcher script to local binary folder..."
cp -f "$(dirname "$0")/antigravity-switcher.sh" "$BIN_DIR/antigravity-switcher"
chmod +x "$BIN_DIR/antigravity-switcher"

# 5. Create Desktop Entries
echo "🖥️ Creating Desktop launchers..."

# Profile A launcher
cat <<EOF > "$APP_DIR/antigravity-a.desktop"
[Desktop Entry]
Name=Antigravity (Profile A)
Comment=Experience liftoff - Profile A (Isolated)
GenericName=Text Editor
Exec=antigravity --user-data-dir $CONFIG_DIR/antigravity-profile-A --extensions-dir $HOME/.antigravity-ext-A %F
Icon=$ICON_DIR/antigravity-a.png
Type=Application
StartupNotify=false
StartupWMClass=antigravity-profile-a
Categories=TextEditor;Development;IDE;
MimeType=application/x-antigravity-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=antigravity --user-data-dir $CONFIG_DIR/antigravity-profile-A --extensions-dir $HOME/.antigravity-ext-A --new-window %F
Icon=$ICON_DIR/antigravity-a.png
EOF

# Profile B launcher
cat <<EOF > "$APP_DIR/antigravity-b.desktop"
[Desktop Entry]
Name=Antigravity (Profile B)
Comment=Experience liftoff - Profile B (Isolated)
GenericName=Text Editor
Exec=antigravity --user-data-dir $CONFIG_DIR/antigravity-profile-B --extensions-dir $HOME/.antigravity-ext-B %F
Icon=$ICON_DIR/antigravity-b.png
Type=Application
StartupNotify=false
StartupWMClass=antigravity-profile-b
Categories=TextEditor;Development;IDE;
MimeType=application/x-antigravity-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=antigravity --user-data-dir $CONFIG_DIR/antigravity-profile-B --extensions-dir $HOME/.antigravity-ext-B --new-window %F
Icon=$ICON_DIR/antigravity-b.png
EOF

# Switcher launcher
cat <<EOF > "$APP_DIR/antigravity-switcher.desktop"
[Desktop Entry]
Type=Application
Name=Antigravity Switcher
Comment=Launch isolated Antigravity profiles concurrently
Exec=$BIN_DIR/antigravity-switcher
Icon=preferences-system-users
Terminal=false
Categories=Development;Utility;
EOF

chmod +x "$APP_DIR"/antigravity-a.desktop "$APP_DIR"/antigravity-b.desktop "$APP_DIR"/antigravity-switcher.desktop
update-desktop-database "$APP_DIR" 2>/dev/null || true

echo "🎉 Installation completed successfully!"
echo "💡 You can now search for 'Antigravity (Profile A)', 'Antigravity (Profile B)', or 'Antigravity Switcher' in your system's application menu."
echo "💡 You can also type 'antigravity-switcher' in any terminal to launch the profile picker!"
