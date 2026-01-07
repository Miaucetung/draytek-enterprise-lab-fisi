# LAB-03: Wireless Multi-SSID mit VLAN-Mapping

**Schwierigkeit:** ⭐⭐ Mittel  
**Dauer:** 2-3 Stunden  
**Voraussetzungen:** LAB-01 und LAB-02 abgeschlossen

## Ziel

Nach diesem Lab können Sie:
- ✅ Multiple SSIDs am DrayTek Router konfigurieren
- ✅ SSIDs zu spezifischen VLANs mappen
- ✅ Verschiedene Sicherheitsstufen pro SSID einrichten (WPA2-PSK, WPA2-Enterprise)
- ✅ Client-Isolation für Gäste-WLAN aktivieren
- ✅ Wireless-Performance optimieren (Channel, Bandwidth)
- ✅ WLAN-Troubleshooting durchführen

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax mit integriertem WLAN (oder externes AP)
- Client-Geräte mit WLAN (Laptop, Smartphone, Tablet)
- Ethernet-Verbindung für initiale Konfiguration

### Software
- Web-Browser
- WLAN-fähige Geräte (Windows, Linux, macOS, iOS, Android)

### Kenntnisse
- WLAN-Grundlagen (SSID, WPA2, Channel)
- VLAN-Konzepte (aus LAB-02)
- Windows/Linux WLAN-Konfiguration

### Vorbereitung
- [ ] LAB-02 erfolgreich abgeschlossen (VLANs 10, 20, 30, 99 existieren)
- [ ] Router erreichbar unter https://192.168.99.1 (oder 192.168.10.1)
- [ ] Backup erstellt
- [ ] Mindestens 2 WLAN-fähige Test-Geräte verfügbar

## Ausgangslage

**Szenario:** Das Unternehmen möchte verschiedene WLAN-Netzwerke für verschiedene Benutzergruppen: 

**Anforderungen:**
1. **Mitarbeiter-WLAN:** Sicher (WPA2-Enterprise), Zugriff auf Office-VLAN (10)
2. **Gäste-WLAN:** Einfach (WPA2-PSK), isoliert (VLAN 20), nur Internet
3. **Lab-WLAN:** Entwickler-Zugang (WPA2-PSK), VLAN 30
4. **Admin-WLAN:** Versteckt, nur Management (VLAN 99), WPA2-Enterprise

## WLAN-Design

### SSID-zu-VLAN-Mapping

| SSID | VLAN | Security | Verschlüsselung | Sichtbar | Client Isolation | Zweck |
|------|------|----------|-----------------|----------|------------------|-------|
| Company-Office | 10 | WPA2-Enterprise | AES | Ja | Nein | Mitarbeiter |
| Company-Guest | 20 | WPA2-PSK | AES | Ja | Ja | Gäste |
| Company-Lab | 30 | WPA2-PSK | AES | Nein | Nein | Entwickler |
| Company-Mgmt | 99 | WPA2-Enterprise | AES | Nein | Nein | IT-Admins |

### WLAN-Parameter

```yaml
wireless_settings:
  band_2_4ghz: 
    enabled: true
    channel: 6  # Oder auto
    bandwidth: 20  # MHz (oder 40 für mehr Speed, aber mehr Interferenz)
    tx_power: 100  # % (Medium für Lab, reduzieren für kleinere Räume)
  
  band_5ghz: 
    enabled: true
    channel: 36  # Oder auto
    bandwidth: 80  # MHz (5 GHz hat mehr Kanäle)
    tx_power: 100
  
  general: 
    max_clients_per_ssid: 32
    dtim_interval: 1
    beacon_interval: 100
    rts_threshold: 2347