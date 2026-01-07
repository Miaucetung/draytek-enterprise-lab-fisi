# LAB-05: QoS & Bandwidth Management

**Schwierigkeit:** ⭐⭐⭐ Mittel-Schwer  
**Dauer:** 2-3 Stunden  
**Voraussetzungen:** LAB-01 bis LAB-04 abgeschlossen

## Ziel

Nach diesem Lab können Sie:
- ✅ Quality of Service (QoS) Konzepte verstehen
- ✅ Traffic-Klassifizierung konfigurieren
- ✅ Bandbreiten-Garantien und -Limits setzen
- ✅ VoIP-Traffic priorisieren
- ✅ Guest-Bandwidth limitieren
- ✅ QoS-Performance messen und validieren
- ✅ DSCP-Marking verstehen und anwenden

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax mit konfigurierten VLANs
- Internet-Verbindung mit bekannter Bandbreite
- VoIP-fähiges Gerät (optional, für Tests)
- Clients für Bandwidth-Tests

### Software
- Web-Browser
- Speed-Test-Tools (fast.com, speedtest.net, iperf3)
- Optional: VoIP-Softphone (Zoiper, X-Lite)

### Kenntnisse
- Netzwerk-Grundlagen
- TCP/IP, Ports, Protokolle
- Verständnis von Latenz, Jitter, Packet Loss

### Vorbereitung
- [ ] LAB-04 abgeschlossen (Firewall-Regeln aktiv)
- [ ] Backup erstellt
- [ ] WAN-Bandbreite gemessen (Download/Upload)
- [ ] [config/examples/qos. example.yml](../config/examples/qos.example.yml) gelesen

## Ausgangslage

**Problem-Szenario:**