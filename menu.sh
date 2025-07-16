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
    echo -e "🚀 \e[1;33mKuzco Node Installer\e[0m - Powered by \e[1;33mGoldVPS Team\e[0m 🚀"
    echo -e "🌐 \e[4;33mhttps://goldvps.net\e[0m - Best VPS with Low Price"
    echo ""
}

# === Konfigurasi SSH ===
function enable_root_ssh() {
    echo -e "${CYAN}🔧 Mengatur SSH agar root bisa login...${RESET}"
    SSH_CONFIG="/etc/ssh/sshd_config"

    if grep -q '^PermitRootLogin' "$SSH_CONFIG"; then
        sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$SSH_CONFIG"
    else
        sed -i '/^#LoginGraceTime 2m/a PermitRootLogin yes' "$SSH_CONFIG"
    fi

    systemctl restart ssh
    echo -e "${GREEN}✅ SSH dikonfigurasi. Sekarang atur password root:${RESET}"
    passwd root
}

# === Nonaktifkan IPv6 ===
function disable_ipv6() {
    echo -e "${CYAN}🔧 Menonaktifkan IPv6 secara permanen...${RESET}"
    GRUB_FILE="/etc/default/grub"

    if ! grep -q "ipv6.disable=1" "$GRUB_FILE"; then
        sed -i 's/^GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="ipv6.disable=1 /' "$GRUB_FILE"
        update-grub
        echo -e "${YELLOW}♻️ Rebooting untuk menerapkan perubahan IPv6...${RESET}"
        reboot
    else
        echo -e "${GREEN}✅ IPv6 sudah dinonaktifkan sebelumnya.${RESET}"
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
            echo -e "${RED}Opsi tidak valid!${RESET}"
            ;;
    esac
}

# === Eksekusi ===
show_header
show_menu
