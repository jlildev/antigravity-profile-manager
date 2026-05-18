#!/bin/bash

# Configuration directories
CONFIG_DIR="$HOME/.config"
DEFAULT_USER_DIR="$CONFIG_DIR/Antigravity_Profile_Default/User"

# Detect antigravity executable
if command -v antigravity &>/dev/null; then
    LAUNCHER="antigravity"
elif [ -f "/usr/share/antigravity/antigravity" ]; then
    LAUNCHER="/usr/share/antigravity/antigravity"
else
    # Fallback to standard vs code command if antigravity is not found
    LAUNCHER="code"
fi

# 1. Gather all available profiles
LEGACY_PROFILES=$(ls -d "$CONFIG_DIR"/Antigravity_Profile_* 2>/dev/null | sed "s|$CONFIG_DIR/Antigravity_Profile_||")
ISOLATED_PROFILES=$(ls -d "$CONFIG_DIR"/antigravity-profile-* 2>/dev/null | sed "s|$CONFIG_DIR/||")

ALL_PROFILES=""

# Process legacy profiles
for p in $LEGACY_PROFILES; do
    if [ "$p" != "Default" ]; then
        ALL_PROFILES+="$p\nLegacy Profile (Shared)\n"
    fi
done

# Add default profile explicitly at the top if exists
if [ -d "$CONFIG_DIR/Antigravity_Profile_Default" ]; then
    ALL_PROFILES="Default\nLegacy Profile (Shared)\n$ALL_PROFILES"
fi

# Process isolated profiles
for p in $ISOLATED_PROFILES; do
    # Rename for nice UI: e.g. 'antigravity-profile-A' -> 'Profile A'
    if [ "$p" == "antigravity-profile-A" ]; then
        display_name="Profile A"
    elif [ "$p" == "antigravity-profile-B" ]; then
        display_name="Profile B"
    else
        display_name=$(echo "$p" | sed 's/antigravity-profile-//')
    fi
    ALL_PROFILES+="$display_name\nIsolated Profile (Concurrent)\n"
done

# Ensure we have at least Profile A and Profile B in the list if not detected
if [[ ! "$ALL_PROFILES" =~ "Profile A" ]]; then
    ALL_PROFILES+="Profile A\nIsolated Profile (Concurrent)\n"
fi
if [[ ! "$ALL_PROFILES" =~ "Profile B" ]]; then
    ALL_PROFILES+="Profile B\nIsolated Profile (Concurrent)\n"
fi

# 2. Show the Zenity selection dialog
# We will show columns: Profile Name, Profile Type
SELECTED=$(echo -e "+ Create New Profile\n[Info]\n$ALL_PROFILES" | zenity --list \
    --title="Antigravity Profile Switcher" \
    --text="Choose an Antigravity profile to launch.\nIsolated profiles can run at the same time!" \
    --column="Profile Name" --column="Profile Type" \
    --height=500 --width=450)

# If user cancels or closes the window
if [ -z "$SELECTED" ]; then
    exit 0
fi

# 3. Handle selection
if [ "$SELECTED" == "+ Create New Profile" ]; then
    # Open entry dialog for new profile name
    NEW_NAME=$(zenity --entry --title="Create New Profile" --text="Enter a name for the new isolated profile:")
    
    if [ -n "$NEW_NAME" ]; then
        # Format name for folder
        CLEAN_NAME=$(echo "$NEW_NAME" | sed -e 's/[^a-zA-Z0-9-]/_/g')
        FOLDER_NAME="antigravity-profile-$CLEAN_NAME"
        USER_DATA_DIR="$CONFIG_DIR/$FOLDER_NAME"
        EXT_DIR="$HOME/.antigravity-ext-$CLEAN_NAME"
        
        # Setup directories
        mkdir -p "$USER_DATA_DIR/User"
        mkdir -p "$EXT_DIR"
        
        # Clone default settings to keep extensions/settings matching
        if [ -f "$DEFAULT_USER_DIR/settings.json" ]; then
            ln -sf "$DEFAULT_USER_DIR/settings.json" "$USER_DATA_DIR/User/settings.json"
        fi
        if [ -f "$DEFAULT_USER_DIR/keybindings.json" ]; then
            ln -sf "$DEFAULT_USER_DIR/keybindings.json" "$USER_DATA_DIR/User/keybindings.json"
        fi
        if [ -d "$DEFAULT_USER_DIR/snippets" ]; then
            ln -sfT "$DEFAULT_USER_DIR/snippets" "$USER_DATA_DIR/User/snippets"
        fi
        
        # Launch new isolated profile in background
        "$LAUNCHER" --user-data-dir "$USER_DATA_DIR" --extensions-dir "$EXT_DIR" &
        
        if command -v notify-send &>/dev/null; then
            notify-send "Antigravity" "Created and launched new isolated profile: $NEW_NAME"
        fi
    fi

elif [ "$SELECTED" == "Profile A" ]; then
    "$LAUNCHER" --user-data-dir "$CONFIG_DIR/antigravity-profile-A" --extensions-dir "$HOME/.antigravity-ext-A" &
    if command -v notify-send &>/dev/null; then
        notify-send "Antigravity" "Launching Profile A..."
    fi
    
elif [ "$SELECTED" == "Profile B" ]; then
    "$LAUNCHER" --user-data-dir "$CONFIG_DIR/antigravity-profile-B" --extensions-dir "$HOME/.antigravity-ext-B" &
    if command -v notify-send &>/dev/null; then
        notify-send "Antigravity" "Launching Profile B..."
    fi

else
    # Check if selected profile is in the legacy or isolated format
    if [ -d "$CONFIG_DIR/Antigravity_Profile_$SELECTED" ]; then
        # Legacy profile - we can launch it concurrently as well!
        "$LAUNCHER" --user-data-dir "$CONFIG_DIR/Antigravity_Profile_$SELECTED" --extensions-dir "$HOME/.antigravity-ext-$SELECTED" &
        if command -v notify-send &>/dev/null; then
            notify-send "Antigravity" "Launching profile: $SELECTED (Isolated Mode)"
        fi
    elif [ -d "$CONFIG_DIR/antigravity-profile-$SELECTED" ]; then
        "$LAUNCHER" --user-data-dir "$CONFIG_DIR/antigravity-profile-$SELECTED" --extensions-dir "$HOME/.antigravity-ext-$SELECTED" &
        if command -v notify-send &>/dev/null; then
            notify-send "Antigravity" "Launching profile: $SELECTED"
        fi
    else
        # Fallback to standard launch
        "$LAUNCHER" --user-data-dir "$CONFIG_DIR/Antigravity_Profile_$SELECTED" &
        if command -v notify-send &>/dev/null; then
            notify-send "Antigravity" "Launching profile: $SELECTED"
        fi
    fi
fi
