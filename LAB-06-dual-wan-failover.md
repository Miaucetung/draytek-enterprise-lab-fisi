# LAB-06: Dual-WAN & Failover/Load-Balancing

**Schwierigkeit:** ⭐⭐⭐ Mittel-Schwer  
**Dauer:** 2-3 Stunden  
**Voraussetzungen:** LAB-01 bis LAB-05 abgeschlossen

## Ziel

Nach diesem Lab können Sie:
- ✅ Dual-WAN-Konfiguration verstehen und einrichten
- ✅ Automatisches Failover konfigurieren
- ✅ Load-Balancing zwischen WAN-Verbindungen
- ✅ WAN-Health-Checks einrichten
- ✅ Policy-Based Routing für spezifische Traffic-Flows
- ✅ Failover-Szenarien testen und validieren

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax mit 2 WAN-Ports
- 2 Internet-Verbindungen (WAN1 primary, WAN2 backup)
  - Alternativ: WAN2 simulieren mit mobilem Hotspot/LTE-Router
- Clients für Testing

### Software
- Web-Browser
- `ping`, `traceroute` für Tests
- Speed-Test-Tools

### Kenntnisse
- Routing-Grundlagen
- Failover-Konzepte
- NAT-Verständnis

### Vorbereitung
- [ ] LAB-01 bis LAB-05 abgeschlossen
- [ ] 2 WAN-Verbindungen physisch verfügbar
- [ ] Backup erstellt

## Ausgangslage

**Single-WAN-Risiko:**