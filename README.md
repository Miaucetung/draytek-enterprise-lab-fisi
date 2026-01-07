# 🔐 DrayTek Enterprise Lab für Fachinformatiker Systemintegration

[![License:  MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![DrayTek](https://img.shields.io/badge/DrayTek-2927ax-blue.svg)](https://www.draytek.com/)
[![German](https://img.shields.io/badge/Sprache-Deutsch-green.svg)](README. md)

Ein professionelles, praxisorientiertes Labor-Projekt für die Ausbildung zum Fachinformatiker Systemintegration (IHK/Umschulung) mit Fokus auf **Identity & Access Management (IAM)**, Netzwerksegmentierung und Enterprise-Security.

## 📋 Inhaltsverzeichnis

- [Über das Projekt](#über-das-projekt)
- [Lernziele](#lernziele)
- [Voraussetzungen](#voraussetzungen)
- [Quickstart](#quickstart)
- [Labor-Übersicht](#labor-übersicht)
- [Dokumentation](#dokumentation)
- [IHK-Dokumentation](#ihk-dokumentation)
- [Sicherheitshinweise](#sicherheitshinweise)
- [Lizenz](#lizenz)

## 🎯 Über das Projekt

Dieses Repository enthält eine vollständige Labor-Umgebung für die professionelle Netzwerk- und Security-Ausbildung mit einem **DrayTek Vigor 2927ax** Router. Der Schwerpunkt liegt auf:

- **Identity & Access Management (IAM)** mit RADIUS und LDAP/Active Directory
- **Netzwerksegmentierung** mit VLANs und Zone-Based Firewall
- **VPN-Technologien** (IPSec und SSL VPN)
- **Hochverfügbarkeit** (Dual-WAN Failover & Load Balancing)
- **Quality of Service (QoS)** für VoIP-Priorisierung
- **Logging & Monitoring** mit Syslog und SNMP
- **Incident Response** und Troubleshooting

### Für wen ist dieses Projekt? 

✅ **Fachinformatiker Systemintegration** (IHK-Ausbildung/Umschulung)  
✅ **IT-System-Kaufleute** mit Netzwerk-Schwerpunkt  
✅ **Network Engineers** in der Weiterbildung  
✅ **IT-Administratoren** mit DrayTek-Equipment  
✅ **Selbstlerner** mit Interesse an Enterprise-Networking  

## 🎓 Lernziele

Nach Abschluss aller Labor-Übungen können Sie:

- ✅ Ein Enterprise-Netzwerk mit VLANs und Zonen-Segmentierung planen und umsetzen
- ✅ **RADIUS-basierte Authentifizierung** für WLAN (802.1X/WPA2-Enterprise) konfigurieren
- ✅ **Active Directory Integration** über LDAP für zentrale Benutzerverwaltung einrichten
- ✅ Zone-Based Firewall-Policies nach Least-Privilege-Prinzip implementieren
- ✅ VPN-Lösungen (Remote Access & Site-to-Site) produktiv einsetzen
- ✅ Dual-WAN für Hochverfügbarkeit konfigurieren
- ✅ QoS-Policies für geschäftskritische Anwendungen (VoIP) einrichten
- ✅ Umfassendes Logging und Monitoring mit Syslog/SNMP aufbauen
- ✅ Systematisches Troubleshooting bei Netzwerk- und Security-Problemen durchführen
- ✅ Professionelle Dokumentation für IHK-Projekte erstellen

## 🔧 Voraussetzungen

### Hardware

- **DrayTek Vigor 2927ax** Router (oder kompatibles Modell:  2927, 2962, 3910)
- Managed Switch mit VLAN-Unterstützung (empfohlen)
- Access Point(s) für WLAN-Labs (optional, wenn integriertes WLAN genutzt wird)
- Test-Clients:  Windows 10/11, Linux (Ubuntu/Debian)
- Optional: Windows Server 2019/2022 für AD/LDAP-Lab (kann VM sein)

### Software & Tools

- **Webbrowser** für DrayTek WebUI (Firefox/Chrome empfohlen)
- **Putty** oder andere SSH/Telnet-Clients
- **Wireshark** für Paketanalyse
- **Syslog-Server**:  Kiwi Syslog Viewer, syslog-ng, oder rsyslog
- **Monitoring**:  PRTG, LibreNMS, Zabbix oder Nagios
- **Optional**: Packet Tracer oder GNS3 für Vorab-Planung

### Kenntnisse

- Grundlagen TCP/IP (Subnetting, Routing, NAT)
- Grundlagen VLAN (802.1Q Tagging)
- Grundlagen WLAN (SSID, WPA2, Verschlüsselung)
- Windows/Linux Administration (Grundkenntnisse)

## 🚀 Quickstart

### Minimaler Lernpfad (ca. 20-30 Stunden)

1. **[LAB-01: Baseline Hardening](labs/LAB-01-baseline-hardening.md)** ⏱️ 2h  
   → Router absichern, Admin-Zugang härten

2. **[LAB-02: LAN Subnets & VLANs](labs/LAB-02-lan-subnets-vlan.md)** ⏱️ 3h  
   → Netzwerksegmentierung mit VLANs 10/20/30/99

3. **[LAB-03: Multi-SSID Wireless VLANs](labs/LAB-03-multi-ssid-wireless-vlan.md)** ⏱️ 2h  
   → Getrennte WLANs für Office/Guest/Lab

4. **[LAB-04: Firewall, NAT & DMZ](labs/LAB-04-firewall-nat-dmz.md)** ⏱️ 4h  
   → Zone-Based Firewall und Zugriffsregeln

5. **[LAB-08: RADIUS Internal](labs/LAB-08-radius-internal. md)** ⏱️ 4h  
   → ⭐ **IAM-Fokus:** Zentrale Authentifizierung mit RADIUS

6. **[LAB-09: LDAP/AD Integration](labs/LAB-09-ldap-ad-integration.md)** ⏱️ 5h  
   → ⭐ **IAM-Fokus:** Active Directory Integration

7. **[LAB-10: Syslog & SNMP Monitoring](labs/LAB-10-syslog-snmp-monitoring.md)** ⏱️ 3h  
   → Logging und Überwachung

8. **[LAB-11: Incident Simulation](labs/LAB-11-incident-simulation.md)** ⏱️ 3h  
   → Störungsbehandlung und Dokumentation

### Vollständiger Lernpfad

Für das komplette Enterprise-Skill-Set alle 11 Labs in Reihenfolge durcharbeiten (ca. 40-50 Stunden).

## 📚 Labor-Übersicht

| Lab | Titel | Schwerpunkt | Dauer | Schwierigkeit |
|-----|-------|-------------|-------|---------------|
| 01 | [Baseline Hardening](labs/LAB-01-baseline-hardening.md) | Security Baseline | 2h | ⭐ Einfach |
| 02 | [LAN Subnets & VLANs](labs/LAB-02-lan-subnets-vlan.md) | Netzwerksegmentierung | 3h | ⭐⭐ Mittel |
| 03 | [Multi-SSID Wireless](labs/LAB-03-multi-ssid-wireless-vlan.md) | WLAN-Segmentierung | 2h | ⭐⭐ Mittel |
| 04 | [Firewall, NAT & DMZ](labs/LAB-04-firewall-nat-dmz.md) | Firewall-Policies | 4h | ⭐⭐⭐ Fortgeschritten |
| 05 | [Dual-WAN Failover](labs/LAB-05-dual-wan-failover-loadbalance.md) | Hochverfügbarkeit | 3h | ⭐⭐⭐ Fortgeschritten |
| 06 | [QoS & VoIP Priority](labs/LAB-06-qos-voip-priority. md) | Quality of Service | 3h | ⭐⭐⭐ Fortgeschritten |
| 07 | [VPN Remote Access](labs/LAB-07-vpn-remote-access. md) | VPN-Technologien | 4h | ⭐⭐⭐ Fortgeschritten |
| 08 | [RADIUS Internal](labs/LAB-08-radius-internal.md) | **IAM:  RADIUS** | 4h | ⭐⭐⭐⭐ Profi |
| 09 | [LDAP/AD Integration](labs/LAB-09-ldap-ad-integration.md) | **IAM: Directory Services** | 5h | ⭐⭐⭐⭐ Profi |
| 10 | [Syslog & SNMP](labs/LAB-10-syslog-snmp-monitoring. md) | Monitoring & Logging | 3h | ⭐⭐ Mittel |
| 11 | [Incident Simulation](labs/LAB-11-incident-simulation.md) | Troubleshooting | 3h | ⭐⭐⭐ Fortgeschritten |

## 📖 Dokumentation

- **[00-Overview](docs/00-overview.md)** - Projektübersicht und Konzepte
- **[01-Lab Environment](docs/01-lab-environment.md)** - Hardware-Setup und Tools
- **[02-Addressing & VLAN Plan](docs/02-addressing-vlan-plan.md)** - IP-Adressierung und VLAN-Schema
- **[03-Security Baseline](docs/03-security-baseline.md)** - Sicherheits-Grundkonfiguration
- **[04-Logging & Monitoring](docs/04-logging-monitoring.md)** - Logging-Strategie
- **[05-Troubleshooting Playbook](docs/05-troubleshooting-playbook.md)** - Systematische Fehlersuche
- **[06-Templates](docs/06-templates.md)** - Dokumentationsvorlagen
- **[07-Assessment Checklists](docs/07-assessment-checklists.md)** - Selbstbewertung

### Netzwerk-Diagramme

- **[Network Topology](diagrams/topology.mmd)** - Gesamtübersicht
- **[VLAN Zones](diagrams/vlan-zones.mmd)** - Sicherheitszonen
- **[RADIUS Flow](diagrams/radius-flow.mmd)** - Authentifizierungs-Ablauf
- **[VPN Site-to-Site](diagrams/vpn-site2site.mmd)** - VPN-Architektur

## 📝 IHK-Dokumentation

### Konfiguration sicher exportieren

**WICHTIG:** DrayTek-Konfigurationen können Passwörter und Pre-Shared Keys enthalten! 

```bash
# Konfiguration über WebUI exportieren: 
# System Maintenance > Config Backup > Backup Configuration
# Datei speichern als: config-YYYY-MM-DD-sanitized.cfg

# Vor dem Commit bereinigen:
# 1. Öffne . cfg mit Texteditor
# 2. Ersetze alle Passwörter durch "PLACEHOLDER"
# 3. Ersetze alle PSKs durch "PLACEHOLDER"
# 4. Speichere in:  config/exports/
```

**NIEMALS echte Credentials ins Repository committen!**

### Was für IHK dokumentieren? 

Für IHK-Projektarbeiten sollten folgende Artefakte erstellt werden:

#### 1. Netzwerkplan (Pflicht)
- IP-Adressplan (siehe [VLAN-Plan Vorlage](config/examples/vlan-plan.example.yml))
- Netzwerk-Topologie-Diagramm
- VLAN-Übersicht mit Zweck jedes Segments

#### 2. Konfigurationsdokumentation
- Firewall-Regeln mit Begründung (siehe [Firewall-Policy Vorlage](config/examples/firewall-policy.example. yml))
- RADIUS/LDAP-Konfiguration (IAM-Konzept)
- VPN-Profile und Zugriffsrechte
- QoS-Policies mit Business-Begründung

#### 3. Testprotokolle
- Für jedes Lab: Durchführung, Testergebnisse, Screenshots
- Nutze Validierungs-Abschnitt aus jedem Lab
- Beispiel-Testprotokoll:  siehe [Templates](docs/06-templates.md)

#### 4. Störungsbehandlung
- LAB-11 liefert Incident-Report-Vorlage
- Dokumentiere Fehlerbilder, Analyse, Lösung

#### 5. Reflexion & Fazit
- Was wurde gelernt?
- Welche Probleme traten auf?
- Wie würde man es in Production umsetzen?

### Vorlagen

Alle YAML-Vorlagen in `config/examples/` können als Basis für IHK-Dokumentation verwendet werden:

- `vlan-plan.example.yml` → IP-Adressplan
- `firewall-policy.example.yml` → Firewall-Doku
- `radius-users.example.yml` → IAM-Konzept
- `vpn-profiles.example.yml` → VPN-Doku

## 🛡️ Sicherheitshinweise

### Labor-Umgebung isolieren

⚠️ **Dieses Lab sollte NICHT direkt am Produktiv-Netz betrieben werden!**

Empfohlene Isolation:
- Separates physisches Netzwerk
- Oder:  Dediziertes VLAN im Produktiv-Netz
- Oder:  Komplett virtualisiert (GNS3/EVE-NG)

### Keine echten Credentials

- ❌ **NIEMALS** echte Produktiv-Passwörter verwenden
- ❌ **NIEMALS** echte API-Keys oder Zertifikate committen
- ✅ Nutze `PLACEHOLDER` in allen Beispiel-Konfigurationen
- ✅ Nutze `secrets. example` Pattern

### Firewall-Regeln testen

Vor Produktiv-Einsatz: 
1. Alle Regeln in Testumgebung validieren
2. Logging aktivieren und Logs prüfen
3. Ungewollte Blockierungen identifizieren
4. Change-Management-Prozess einhalten

## 🧪 Test-Scripts

### Windows (PowerShell)

```powershell
# Netzwerk-Konnektivität testen
.\scripts\windows\Test-Network. ps1

# RADIUS-Authentifizierung testen
.\scripts\windows\Test-Radius.ps1

# Logs sammeln
.\scripts\windows\Collect-Logs.ps1
```

### Linux (Bash)

```bash
# Netzwerk-Konnektivität testen
./scripts/linux/test-network.sh

# RADIUS-Authentifizierung testen
./scripts/linux/test-radius.sh

# Logs sammeln
./scripts/linux/collect-logs.sh
```

## 📊 Assessment

- **[Bewertungs-Rubrik](assessment/rubric.md)** - Bewertungskriterien für jedes Lab
- **[Prüfungsfragen](assessment/exam-style-questions.md)** - 50+ Übungsfragen

## 🤝 Beitragen

Contributions sind willkommen! Siehe [CONTRIBUTING.md](CONTRIBUTING.md) für Details.

## 📜 Lizenz

Dieses Projekt ist lizenziert unter der MIT-Lizenz - siehe [LICENSE](LICENSE) für Details.

## 🙏 Danksagungen

- DrayTek für umfassende Dokumentation
- IHK für strukturierte Ausbildungsinhalte
- Die Open-Source-Community für Tools und Inspiration

## 📞 Support

- **Issues:** Nutze GitHub Issues für Bugs und Feature-Requests
- **Diskussionen:** GitHub Discussions für Fragen und Austausch
- **Security:** Siehe [SECURITY.md](SECURITY.md) für Security-Meldungen

---

**Viel Erfolg bei der Ausbildung zum Fachinformatiker Systemintegration!  🚀**
