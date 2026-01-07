# Labor-Umgebung

## Hardware-Anforderungen

### DrayTek Router (Erforderlich)

**Primär unterstützt:**
- **DrayTek Vigor 2927ax** (empfohlen)
  - Dual-WAN
  - Integriertes WLAN (Wi-Fi 6)
  - VLAN-Support
  - Interner RADIUS-Server
  - VPN (IPSec, SSL)
  - QoS

**Alternativ kompatibel:**
- DrayTek Vigor 2927
- DrayTek Vigor 2962
- DrayTek Vigor 3910

**Wichtig:** Prüfe vor Kauf, ob dein Modell folgende Features unterstützt:
- ✅ VLAN (802.1Q)
- ✅ Interner RADIUS-Server (für LAB-08)
- ✅ LDAP-Client-Funktionalität (für LAB-09)
- ✅ SSL VPN
- ✅ IPSec VPN
- ✅ Syslog-Client
- ✅ SNMP v2c/v3

### Netzwerk-Switch (Optional, aber empfohlen)

**Managed Switch mit VLAN-Support:**
- TP-Link TL-SG108E (8-Port, günstig)
- Netgear GS308E (8-Port)
- Cisco SG350 Series (professionell)
- HP/Aruba 1920S Series

**Erforderliche Features:**
- 802.1Q VLAN Tagging
- Trunk Ports
- Access Ports
- Web-Management oder CLI

**Ohne Switch:** VLAN-Konfiguration nur am Router möglich (eingeschränkte Lab-Möglichkeiten)

### Wireless Access Point (Optional)

**Wenn Router-WLAN nicht ausreicht:**
- DrayTek VigorAP (für einheitliches Management)
- UniFi AP AC Lite/LR
- TP-Link EAP Series

**Erforderliche Features:**
- Multiple SSIDs
- VLAN-Tagging pro SSID
- WPA2-Enterprise (802.1X)
- Zentrale Management-Möglichkeit

### Client-Geräte

**Minimum:**
- 1x Windows 10/11 Laptop/PC
- 1x Linux-System (Ubuntu 22.04 LTS empfohlen)

**Empfohlen:**
- 2-3x Windows-Clients (für RADIUS-Tests, verschiedene VLANs)
- 1-2x Linux-Clients
- 1x macOS-Client (optional)
- Smartphones/Tablets für WLAN-Tests

### Server (für erweiterte Labs)

**Für LAB-09 (LDAP/AD):**
- **Windows Server 2019/2022** (kann VM sein)
  - Mindestens 4 GB RAM
  - 60 GB HDD
  - Active Directory Domain Services
  - DNS Server Role

**Für LAB-10 (Logging/Monitoring):**
- **Linux Server** (Ubuntu/Debian/CentOS)
  - 2 GB RAM
  - 20 GB HDD
  - Syslog-Server (syslog-ng oder rsyslog)
  - Optional: LibreNMS, Zabbix, oder Nagios

**Virtualisierung möglich:**
- VMware Workstation/Player
- VirtualBox (kostenlos)
- Hyper-V (Windows Pro/Enterprise)
- Proxmox (für dedizierte Lab-Hardware)

### Kabelinfrastruktur

**Minimum:**
- 5x Cat5e/Cat6 Ethernet-Kabel (1-3m)
- 1x Längeres Kabel (10-20m) für WAN-Simulation

**Empfohlen:**
- 10x Cat6 Ethernet-Kabel (verschiedene Längen)
- Kabel-Labels für Dokumentation
- Kabel-Management (Klettverschluss)

## Software-Anforderungen

### Router-Firmware

**Empfohlene Firmware-Version:**
- DrayTek Vigor 2927ax: **v4.3.1 oder höher**
- Prüfe aktuelle Version:  [DrayTek Download Center](https://www.draytek.com/support/downloads/)

**Update-Prozess:**
1. Aktuelle Firmware herunterladen
2. Backup der Konfiguration erstellen
3. Firmware über WebUI hochladen
4. Router neu starten
5. Konfiguration prüfen

### Management-Software

#### Web Browser
- **Firefox** (empfohlen)
- Chrome/Edge (alternativ)
- **Nicht empfohlen:** Internet Explorer

**Browser-Erweiterungen:**
- Passwort-Manager (KeePassXC, Bitwarden)
- Screenshot-Tool
- Developer Tools (eingebaut)

#### SSH/Telnet Client
**Windows:**
- PuTTY (kostenlos)
- MobaXterm (erweiterte Features)
- Windows Terminal mit OpenSSH

**Linux/macOS:**
- OpenSSH (bereits installiert)
- Terminal-Emulator deiner Wahl

### Netzwerk-Analyse-Tools

#### Wireshark (Packet Capture)
```bash
# Windows:  Download von https://www.wireshark.org/
# Linux: 
sudo apt install wireshark
sudo usermod -aG wireshark $USER

# macOS:
brew install --cask wireshark