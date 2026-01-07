# LAB-10: Logging, Monitoring & SNMP

**Schwierigkeit:** ⭐⭐⭐ Mittel  
**Dauer:** 3-4 Stunden  
**Voraussetzungen:** LAB-01 bis LAB-09 abgeschlossen

## Ziel

Nach diesem Lab können Sie:
- ✅ Zentralisierten Syslog-Server aufsetzen (Linux)
- ✅ DrayTek-Logs zu Syslog forwarden
- ✅ SNMP für Monitoring konfigurieren
- ✅ Monitoring-System aufsetzen (PRTG oder LibreNMS)
- ✅ Alerting und Notifications einrichten
- ✅ Log-Analyse durchführen
- ✅ Performance-Metriken sammeln und visualisieren

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax (konfiguriert aus LAB-01-09)
- Linux-Server (VM) für Syslog (Ubuntu 22.04)
  - 2 GB RAM, 40 GB Disk
- Optional: Windows-Server für PRTG oder Linux für LibreNMS

### Software
- Ubuntu 22.04 LTS ISO
- syslog-ng oder rsyslog
- SNMP-Tools (snmpwalk, snmpget)
- Optional: PRTG Network Monitor, LibreNMS, Zabbix

### Kenntnisse
- Linux-Grundlagen (apt, systemctl, nano)
- Syslog-Konzepte (Facility, Severity)
- SNMP-Basics (OID, MIB, Community String)

### Vorbereitung
- [ ] LAB-01 bis LAB-09 abgeschlossen
- [ ] Ubuntu-VM für Syslog erstellt (192.168.99.10)
- [ ] Backup erstellt
- [ ] [config/examples/syslog. example.yml](../config/examples/syslog. example.yml) gelesen

## Ausgangslage

**Aktueller Zustand:**
