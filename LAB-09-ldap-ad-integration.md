# LAB-09: LDAP/Active Directory Integration

**Schwierigkeit:** ⭐⭐⭐⭐⭐ Sehr Schwer  
**Dauer:** 4-5 Stunden  
**Voraussetzungen:** LAB-01 bis LAB-08 abgeschlossen, Windows Server verfügbar

## Ziel

Nach diesem Lab können Sie:
- ✅ Active Directory-Server aufsetzen (Grundlagen)
- ✅ LDAP-Anbindung am DrayTek konfigurieren
- ✅ RADIUS mit LDAP-Backend integrieren
- ✅ AD-Gruppen zu VLAN-Zuordnungen mappen
- ✅ Single Sign-On (SSO) für Netzwerk-Zugang
- ✅ Zentralisierte User-Verwaltung implementieren
- ✅ LDAP-Troubleshooting durchführen

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax
- Windows Server 2019/2022 (VM oder physisch)
  - Min.  4 GB RAM, 60 GB Disk
  - Oder:  Samba AD DC (Linux-Alternative)
- Test-Clients (Windows/Linux)

### Software
- Windows Server 2019/2022 ISO
- Hyper-V, VMware, oder VirtualBox
- Active Directory Users and Computers (ADUC)
- LDAP Browser (z.B. Apache Directory Studio) - optional

### Kenntnisse
- Active Directory Basics (Domain, OU, Groups)
- LDAP-Konzepte (DN, CN, OU, DC)
- Windows Server Administration
- RADIUS-Grundlagen (LAB-08)

### Vorbereitung
- [ ] LAB-08 abgeschlossen (RADIUS funktioniert)
- [ ] Windows Server VM erstellt
- [ ] Statische IP für AD-Server:  192.168.50.10
- [ ] Backup erstellt

## Ausgangslage

**Aktuell (nach LAB-08):**
