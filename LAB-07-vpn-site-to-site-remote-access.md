# LAB-07: VPN - Site-to-Site & Remote Access

**Schwierigkeit:** ⭐⭐⭐⭐ Schwer  
**Dauer:** 3-4 Stunden  
**Voraussetzungen:** LAB-01 bis LAB-06 abgeschlossen

## Ziel

Nach diesem Lab können Sie:
- ✅ IPSec Site-to-Site-VPN zwischen zwei Standorten konfigurieren
- ✅ SSL VPN für Remote-User einrichten
- ✅ VPN-Verschlüsselung und -Authentifizierung verstehen
- ✅ Pre-Shared Keys (PSK) sicher verwalten
- ✅ VPN-Performance messen und optimieren
- ✅ VPN-Troubleshooting systematisch durchführen

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax mit WAN-Verbindung
- Optional:  Zweiter DrayTek-Router für Site-to-Site (oder Simulation)
- Remote-Client-Geräte (Laptop, Smartphone)

### Software
- Web-Browser
- DrayTek Smart VPN Client (für SSL VPN)
- Optional: Windows/macOS Built-in VPN-Client

### Kenntnisse
- IPSec-Grundlagen (Phase 1/2, IKE, ESP)
- Verschlüsselungskonzepte (AES, SHA)
- Public/Private Key Konzepte
- NAT und Port-Forwarding

### Vorbereitung
- [ ] LAB-01 bis LAB-06 abgeschlossen
- [ ] Öffentliche WAN-IP verfügbar (für VPN-Zugriff)
- [ ] Backup erstellt
- [ ] [config/examples/vpn-profiles.example.yml](../config/examples/vpn-profiles.example.yml) gelesen
- [ ] Starke PSKs generiert (32+ Zeichen)

## Ausgangslage

**Szenarien für VPN:**

**1. Site-to-Site VPN:**