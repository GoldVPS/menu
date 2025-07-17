#!/bin/bash
set -e

# === Warna terminal ===
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'
BLUE_LINE="\e[38;5;220m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"

# === Tampilkan Header ===
function show_header() {
    clear
    echo -e "\e[38;5;220m"
    echo " ██████╗  ██████╗ ██╗     ██████╗ ██╗   ██╗██████╗ ███████╗"
    echo "██╔════╝ ██╔═══██╗██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝"
    echo "██║  ███╗██║   ██║██║     ██║  ██║██║   ██║██████╔╝███████╗"
    echo "██║   ██║██║   ██║██║     ██║  ██║╚██╗ ██╔╝██╔═══╝ ╚════██║"
    echo "╚██████╔╝╚██████╔╝███████╗██████╔╝ ╚████╔╝ ██║     ███████║"
    echo " ╚═════╝  ╚═════╝ ╚══════╝╚═════╝   ╚═══╝  ╚═╝     ╚══════╝"
    echo -e "\e[0m"
    echo -e "🚀 \e[1;33mConfiguration Auto Installer\e[0m - Powered by \e[1;33mGoldVPS Team\e[0m 🚀"
    echo -e "🌐 \e[4;33mhttps://goldvps.net\e[0m - Best VPS with Low Price"
    echo ""
}

# === Persiapan Awal: Update dan Install nano ===
function prepare_environment() {
    echo -e "${CYAN}🔧 Melakukan update dan instalasi nano...${RESET}"
    apt update -y && apt install nano -y
    echo -e "${GREEN}✅ Update selesai dan nano terpasang.${RESET}"
}

# === Konfigurasi SSH ===
function enable_root_ssh() {
    echo -e "${YELLOW}[*] Mengaktifkan login root via SSH...${RESET}"

    SSH_CONFIG="/etc/ssh/sshd_config"
    BACKUP_PATH="${SSH_CONFIG}.bak"

    # Backup config SSH
    cp "$SSH_CONFIG" "$BACKUP_PATH"

    # Cek apakah ada PermitRootLogin
    if grep -Eq '^\s*#?\s*PermitRootLogin\s+' "$SSH_CONFIG"; then
        sed -i -E 's|^\s*#?\s*PermitRootLogin\s+.*|PermitRootLogin yes|' "$SSH_CONFIG"
        echo -e "${GREEN}[✔] Baris PermitRootLogin berhasil diubah.${RESET}"
    else
        sed -i '/^\s*#\?\s*LoginGraceTime\s\+/a PermitRootLogin yes' "$SSH_CONFIG"
        echo -e "${GREEN}[✔] Baris PermitRootLogin ditambahkan setelah LoginGraceTime.${RESET}"
    fi

    # Set password root
    echo -e "${YELLOW}[*] Silakan masukkan password baru untuk user root:${RESET}"
    passwd root

    # Restart SSH
    echo -e "${YELLOW}[*] Merestart SSH...${RESET}"
    systemctl restart sshd

    echo -e "${GREEN}[✔] Root login aktif dan SSH sudah direstart.${RESET}"
}

# === Nonaktifkan IPv6 ===
function disable_ipv6() {
    echo -e "${CYAN}🔧 Menonaktifkan IPv6 secara permanen...${RESET}"
    GRUB_FILE="/etc/default/grub"

    if grep -q "ipv6.disable=1" "$GRUB_FILE"; then
        echo -e "${GREEN}✅ IPv6 sudah dinonaktifkan sebelumnya.${RESET}"
    else
        sed -i 's/^GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="ipv6.disable=1 /' "$GRUB_FILE"
        update-grub
        echo -e "${YELLOW}♻️ Rebooting untuk menerapkan perubahan IPv6...${RESET}"
        reboot
    fi
}

# === Menu Interaktif ===
function show_menu() {
    echo -e "${BLUE_LINE}"
    echo -e "Pilih opsi instalasi:"
    echo -e "1. Aktifkan login root via SSH"
    echo -e "2. Nonaktifkan IPv6"
    echo -e "3. Keluar"
    echo -e "${BLUE_LINE}"
    read -p "Masukkan angka (1/2/3): " pilihan

    case $pilihan in
        1)
            enable_root_ssh
            ;;
        2)
            disable_ipv6
            ;;
        3)
            echo -e "${YELLOW}Keluar...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opsi tidak valid!${RESET}"
            ;;
    esac
}

# === Eksekusi ===
show_header
prepare_environment
show_menu
