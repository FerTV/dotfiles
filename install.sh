#!/usr/bin/env bash
# install.sh — FerTV/dotfiles post-install for Arch Linux + Hyprland
#
# Run it as your normal user (with sudo) on a fresh `archinstall` base system:
#   git clone https://github.com/FerTV/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && ./install.sh          # add --dev for Podman + QEMU/libvirt
#
# Safe to run again: packages use --needed and configs are re-stowed.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_PKGS=(btop cava dunst eww gtk hypr kitty rofi starship swaync waybar yazi zsh)
DEV=0

usage() {
  cat <<EOF
Usage: ./install.sh [--dev]
  --dev   also install packages-dev.txt (Podman, QEMU/KVM, libvirt, virt-manager)
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dev) DEV=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

log()  { printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!] %s\033[0m\n' "$*"; }

read_list() { grep -vE '^[[:space:]]*(#|$)' "$1"; }

# Install official-repo packages, skipping (and reporting) any name pacman doesn't know.
install_repo() {
  local ok=() missing=() p
  for p in "$@"; do
    if pacman -Si "$p" &>/dev/null || pacman -Sg "$p" &>/dev/null; then ok+=("$p"); else missing+=("$p"); fi
  done
  ((${#missing[@]})) && warn "Not found in the repos, skipped: ${missing[*]}"
  ((${#ok[@]})) && sudo pacman -S --needed --noconfirm "${ok[@]}"
}

# Same for AUR packages, through yay.
install_aur() {
  local ok=() missing=() p
  for p in "$@"; do
    if yay -Si --aur "$p" &>/dev/null; then ok+=("$p"); else missing+=("$p"); fi
  done
  ((${#missing[@]})) && warn "Not found in the AUR, skipped: ${missing[*]}"
  ((${#ok[@]})) && yay -S --needed --noconfirm --answerdiff None --answerclean None --removemake "${ok[@]}"
}

# ---------------------------------------------------------------------------
[[ $EUID -eq 0 ]] && { echo "Run this as your normal user (it uses sudo), not as root."; exit 1; }
command -v pacman >/dev/null || { echo "This script is for Arch Linux."; exit 1; }
sudo -v

# 1. pacman: multilib (Steam, lib32 drivers) and parallel downloads -----------
log "Configuring pacman"
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
  sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//}' /etc/pacman.conf
fi
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sudo pacman -Syu --noconfirm

# 2. Official packages -------------------------------------------------------
log "Installing packages from packages-repo.txt"
mapfile -t REPO_PKGS < <(read_list "$DOTFILES/packages-repo.txt")

# archinstall may already have put in a prebuilt NVIDIA module that conflicts with the DKMS one.
if pacman -Qq nvidia-open &>/dev/null || pacman -Qq nvidia-open-lts &>/dev/null; then
  warn "Prebuilt nvidia-open already installed; keeping it instead of nvidia-open-dkms."
  filtered=()
  for p in "${REPO_PKGS[@]}"; do [[ $p == nvidia-open-dkms ]] || filtered+=("$p"); done
  REPO_PKGS=("${filtered[@]}")
fi
# DKMS needs headers for every installed kernel (the list already has linux-lts-headers).
pacman -Qq linux &>/dev/null && REPO_PKGS+=(linux-headers)

install_repo "${REPO_PKGS[@]}"

# 3. yay + AUR ----------------------------------------------------------------
if ! command -v yay >/dev/null; then
  log "Installing yay"
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

log "Installing packages from packages-aur.txt"
mapfile -t AUR_PKGS < <(read_list "$DOTFILES/packages-aur.txt")
install_aur "${AUR_PKGS[@]}"

# 4. Optional: containers and VMs ---------------------------------------------
if ((DEV)); then
  log "Installing packages from packages-dev.txt"
  mapfile -t DEV_PKGS < <(read_list "$DOTFILES/packages-dev.txt")
  install_repo "${DEV_PKGS[@]}"
  sudo systemctl enable libvirtd.service
  sudo usermod -aG libvirt "$USER"
  # Rootless Podman needs subordinate UID/GID ranges.
  if ! grep -q "^$USER:" /etc/subuid 2>/dev/null; then
    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
  fi
fi

# 5. NVIDIA -------------------------------------------------------------------
log "Configuring NVIDIA"
echo 'options nvidia_drm modeset=1' | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null
# Without the kms hook the initramfs doesn't pull in nouveau.
if grep -qE '^HOOKS=.*\bkms\b' /etc/mkinitcpio.conf; then
  sudo sed -i -E '/^HOOKS=/ s/ kms//' /etc/mkinitcpio.conf
fi
sudo mkinitcpio -P

# 6. GRUB dual boot with Windows ----------------------------------------------
if [[ -f /etc/default/grub ]]; then
  log "GRUB: detecting Windows"
  if grep -qE '^#?GRUB_DISABLE_OS_PROBER=' /etc/default/grub; then
    sudo sed -i -E 's/^#?GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
  else
    echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub >/dev/null
  fi
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  if ! sudo grep -qi windows /boot/grub/grub.cfg; then
    warn "Windows wasn't added to GRUB. Check that its EFI partition exists, then run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
  fi
else
  warn "GRUB not found (another bootloader?); skipping the dual-boot setup."
fi

# 7. zram (only if archinstall didn't set it up) ------------------------------
if [[ ! -f /etc/systemd/zram-generator.conf ]]; then
  log "Configuring zram"
  sudo tee /etc/systemd/zram-generator.conf >/dev/null <<'EOF'
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
EOF
fi

# 8. Services ----------------------------------------------------------------
log "Enabling services"
sudo systemctl enable NetworkManager.service bluetooth.service cups.service paccache.timer
for dm in sddm gdm lightdm; do
  sudo systemctl disable "$dm.service" &>/dev/null || true
done
# Newer ly packages ship a templated unit that runs on a given tty.
if systemctl list-unit-files 'ly@.service' --no-legend 2>/dev/null | grep -q .; then
  sudo systemctl disable getty@tty2.service &>/dev/null || true
  sudo systemctl enable ly@tty2.service
else
  sudo systemctl enable ly.service
fi

# 9. Shell -------------------------------------------------------------------
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */zsh ]]; then
  log "Setting zsh as your shell"
  sudo chsh -s /usr/bin/zsh "$USER"
fi

# 10. Wallpapers -------------------------------------------------------------
log "Copying wallpapers"
mkdir -p "$HOME/Pictures/wallpapers"
cp --update=none "$DOTFILES"/wallpapers/* "$HOME/Pictures/wallpapers/"
if [[ "$HOME" != "/home/w1nt3r" ]]; then
  sed -i "s#/home/w1nt3r#$HOME#g" \
    "$DOTFILES/hypr/.config/hypr/hyprpaper.conf" \
    "$DOTFILES/hypr/.config/hypr/hyprlock.conf"
  warn "Wallpaper paths changed from /home/w1nt3r to $HOME in hyprpaper.conf and hyprlock.conf."
fi

# 11. Dotfiles ---------------------------------------------------------------
log "Linking configs with stow"
mkdir -p "$HOME/.config"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
for pkg in "${STOW_PKGS[@]}"; do
  [[ -d "$DOTFILES/$pkg" ]] || continue
  # Move aside any real file that would block stow (e.g. the default ~/.zshrc).
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES/$pkg/"}"
    target="$HOME/$rel"
    if [[ -e "$target" || -L "$target" ]] && [[ "$(readlink -f "$target")" != "$src" ]]; then
      mkdir -p "$BACKUP/$(dirname "$rel")"
      mv "$target" "$BACKUP/$rel"
    fi
  done < <(find "$DOTFILES/$pkg" -type f -print0)
  stow --no-folding -d "$DOTFILES" -t "$HOME" --restow "$pkg"
done
[[ -d "$BACKUP" ]] && warn "Your previous configs were moved to $BACKUP"

# ---------------------------------------------------------------------------
log "Done"
cat <<EOF
Reboot, then check:
  nvidia-smi                       # the RTX 5060 Ti and its driver show up
  grep -i windows /boot/grub/grub.cfg
EOF
((DEV)) && echo "  Log out and back in so the libvirt group applies."
exit 0
