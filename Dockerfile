# Ultra-minimal Alpine Linux for WebVM with i3
FROM --platform=i386 i386/alpine:3.22.1

# Install only absolutely essential packages
RUN apk update && apk add --no-cache \
    # Core system
    alpine-base \
    # X11 minimal (updated package names for 3.22+)
    xorg-server \
    xf86-input-libinput \
    xinit \
    # Window manager
    i3wm \
    dmenu \
    # Terminal
    xterm \
    # Basic utilities
    bash \
    nano \
    # Minimal deps
    dbus \
    eudev

# Remove unnecessary packages and cache (aggressive cleanup for 3.22.1)
RUN rm -rf /var/cache/apk/* \
           /var/lib/apk/lists/* \
           /usr/share/man/* \
           /usr/share/doc/* \
           /usr/share/info/* \
           /usr/share/locale/* \
           /usr/lib/gconv/* \
           /usr/share/i18n/locales/* \
           /tmp/* \
           /var/tmp/* \
    && find /usr/lib -name "*.a" -delete \
    && find /usr -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

# Create user
RUN adduser -D -s /bin/bash user && \
    echo 'user:password' | chpasswd && \
    echo 'root:password' | chpasswd

# Minimal i3 configuration
RUN mkdir -p /home/user/.config/i3 && cat > /home/user/.config/i3/config << 'EOF'
# WebVM-optimized i3 config
set $mod Mod4

# Font (minimal)
font pango:monospace 8

# Start terminal
bindsym $mod+Return exec xterm

# Kill window
bindsym $mod+Shift+q kill

# Start dmenu
bindsym $mod+d exec dmenu_run

# Restart i3
bindsym $mod+Shift+r restart

# Exit i3
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"

# Floating mode for all windows (WebVM works better this way)
for_window [class=".*"] floating enable

# Simple workspace switching
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2

# Move to workspace
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
EOF

# Create .xinitrc
RUN echo 'exec i3' > /home/user/.xinitrc && \
    chown -R user:user /home/user

# Create simple startx script
RUN cat > /usr/local/bin/start-i3 << 'EOF'
#!/bin/bash
export DISPLAY=:0
startx /home/user/.xinitrc
EOF
RUN chmod +x /usr/local/bin/start-i3

# Alternative: nano instead of emacs (much lighter, works better in WebVM)
RUN echo 'export EDITOR=nano' >> /home/user/.bashrc && \
    echo 'export TERM=xterm' >> /home/user/.bashrc

WORKDIR /home/user
USER user

CMD ["/bin/bash"]
