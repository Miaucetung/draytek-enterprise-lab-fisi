# LAB-02: LAN Subnets & VLANs (Netzwerksegmentierung)

**Schwierigkeit:** ⭐⭐ Mittel  
**Dauer:** 3-4 Stunden  
**Voraussetzungen:** LAB-01 abgeschlossen, gehärteter Router

## Ziel

Nach diesem Lab können Sie:
- ✅ VLANs konzipieren und am DrayTek Router konfigurieren
- ✅ IP-Adressierungspläne erstellen und umsetzen
- ✅ DHCP-Server pro VLAN konfigurieren
- ✅ Inter-VLAN-Routing einrichten
- ✅ Managed Switch für VLAN-Zuordnung konfigurieren (optional)
- ✅ Netzwerksegmentierung nach Security-Zonen verstehen
- ✅ Troubleshooting bei VLAN-Problemen durchführen

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax (mit LAB-01 Baseline-Konfiguration)
- Managed Switch mit VLAN-Support (empfohlen, aber optional)
- Mindestens 2 Client-Geräte (Windows/Linux)
- Ethernet-Kabel

### Software
- Web-Browser für Router-WebUI
- SSH-Client (optional)
- `ipconfig` / `ip` für IP-Konfiguration
- `ping` für Konnektivitätstests

### Kenntnisse
- IP-Subnetting (CIDR-Notation)
- VLAN-Konzepte (802.1Q Tagging)
- DHCP-Grundlagen
- Routing-Grundlagen

### Vorbereitung
- [ ] LAB-01 erfolgreich abgeschlossen
- [ ] Router erreichbar unter https://192.168.1.1
- [ ] Backup der aktuellen Konfiguration erstellt
- [ ] [docs/02-addressing-vlan-plan.md](../docs/02-addressing-vlan-plan.md) gelesen
- [ ] [config/examples/vlan-plan.example.yml](../config/examples/vlan-plan.example.yml) als Referenz bereit

## Ausgangslage

**Szenario:** Das Unternehmen hat aktuell ein **Flat Network** (alle Geräte in einem Netz:  192.168.1.0/24). Dies führt zu: 

**Problemen:**
- ❌ Keine Trennung zwischen Mitarbeitern und Gästen
- ❌ Gäste können auf interne Server zugreifen
- ❌ Broadcast-Storm-Gefahr bei vielen Geräten
- ❌ Keine granulare Firewall-Kontrolle möglich
- ❌ DSGVO-Compliance fragwürdig
- ❌ Management-Geräte nicht isoliert

**Lösung:** Segmentierung durch VLANs! 

## Netzwerk-Design

### VLAN-Schema

| VLAN ID | Name | Subnet | Gateway | DHCP Range | Zweck | Trust Level |
|---------|------|--------|---------|------------|-------|-------------|
| 10 | Office | 192.168.10.0/24 | . 1 | . 100-. 200 | Mitarbeiter-Arbeitsplätze | Trusted |
| 20 | Guest | 192.168.20.0/24 | .1 | .100-.200 | Gäste, nur Internet | Restricted |
| 30 | Lab | 192.168.30.0/24 | .1 | .100-.200 | Entwicklung/Test | Semi-Trusted |
| 99 | Management | 192.168.99.0/24 | .1 | Kein DHCP | Netzwerkgeräte | Highly Trusted |

### IP-Adressplan

**VLAN 10 (Office):**