# LAB-04: Firewall Rules & Zone-Based Security

**Schwierigkeit:** ⭐⭐⭐ Mittel-Schwer  
**Dauer:** 3-4 Stunden  
**Voraussetzungen:** LAB-01, LAB-02, LAB-03 abgeschlossen

## Ziel

Nach diesem Lab können Sie:
- ✅ Zone-Based Firewall-Konzepte verstehen und umsetzen
- ✅ Firewall-Regeln am DrayTek Router konfigurieren
- ✅ Default-Deny-Policy implementieren
- ✅ Granulare Zugriffskontrolle zwischen VLANs einrichten
- ✅ NAT und Port-Forwarding konfigurieren
- ✅ DoS-Schutz aktivieren
- ✅ Firewall-Logs analysieren
- ✅ Systematisches Troubleshooting bei Firewall-Problemen

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax mit VLANs (LAB-02) und WLAN (LAB-03)
- Mindestens 2 Test-Clients in verschiedenen VLANs
- Internet-Verbindung (für WAN-Tests)

### Software
- Web-Browser
- `ping`, `traceroute` für Tests
- Optional: `nmap` für Port-Scanning-Tests

### Kenntnisse
- Firewall-Grundlagen (Stateful Inspection)
- TCP/IP (Ports, Protokolle)
- VLAN-Konzepte (aus LAB-02)
- Netzwerk-Troubleshooting

### Vorbereitung
- [ ] LAB-02 abgeschlossen (VLANs 10, 20, 30, 99 existieren)
- [ ] LAB-03 abgeschlossen (WLANs konfiguriert)
- [ ] Backup erstellt
- [ ] [docs/03-security-baseline.md](../docs/03-security-baseline. md) gelesen
- [ ] [config/examples/firewall-policy.example.yml](../config/examples/firewall-policy.example.yml) als Referenz

## Ausgangslage

**Aktueller Zustand (nach LAB-02):**