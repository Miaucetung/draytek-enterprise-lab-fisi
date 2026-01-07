# LAB-08: RADIUS Authentication & 802.1X

**Schwierigkeit:** ⭐⭐⭐⭐ Schwer  
**Dauer:** 3-4 Stunden  
**Voraussetzungen:** LAB-01 bis LAB-07 abgeschlossen

## Ziel

Nach diesem Lab können Sie:
- ✅ Internen RADIUS-Server am DrayTek konfigurieren
- ✅ 802.1X (WPA2-Enterprise) für WLAN einrichten
- ✅ RADIUS-User und -Gruppen verwalten
- ✅ Dynamische VLAN-Zuweisung über RADIUS
- ✅ RADIUS-Accounting aktivieren
- ✅ Windows/Linux/Mobile Clients für 802.1X konfigurieren
- ✅ RADIUS-Troubleshooting systematisch durchführen

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax mit WLAN
- VLANs konfiguriert (LAB-02, LAB-03)
- Windows/Linux/Mobile Test-Clients

### Software
- Web-Browser
- Optional:   Wireshark für Packet-Analyse
- Windows:   Event Viewer für 802.1X-Logs

### Kenntnisse
- RADIUS-Grundlagen (AAA:   Authentication, Authorization, Accounting)
- 802.1X/EAP-Konzepte
- WLAN-Security (WPA2-PSK vs.  Enterprise)

### Vorbereitung
- [ ] LAB-03 abgeschlossen (WLANs mit WPA2-PSK aktiv)
- [ ] Backup erstellt
- [ ] [config/examples/radius-users.example.yml](../config/examples/radius-users. example.yml) gelesen
- [ ] Test-User-Liste vorbereitet

## Ausgangslage

**Aktueller Zustand (nach LAB-03):**
