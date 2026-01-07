# LAB-01: Baseline Hardening (Grundabsicherung)

**Schwierigkeit:** ⭐ Einfach  
**Dauer:** 2 Stunden  
**Voraussetzungen:** DrayTek Router, Zugang zur WebUI

## Ziel

Nach diesem Lab können Sie:
- ✅ Einen DrayTek-Router sicher konfigurieren
- ✅ Admin-Zugang härten und absichern
- ✅ Unnötige Dienste deaktivieren
- ✅ Firmware aktualisieren
- ✅ Konfiguration sichern und wiederherstellen
- ✅ System-Logs aktivieren und prüfen

## Voraussetzungen

### Hardware
- DrayTek Vigor 2927ax (oder kompatibles Modell)
- PC/Laptop mit Ethernet-Anschluss
- Ethernet-Kabel

### Software
- Web-Browser (Firefox oder Chrome empfohlen)
- Passwort-Manager (KeePassXC, Bitwarden, o.ä.)
- Texteditor für Notizen

### Kenntnisse
- Grundlegende Netzwerk-Kenntnisse
- Browser-Bedienung
- Umgang mit Passwörtern

## Ausgangslage

**Szenario:** Sie haben einen neuen DrayTek Vigor 2927ax Router erhalten oder einen Router auf Werkseinstellungen zurückgesetzt. Der Router hat noch die Default-Konfiguration: 

```yaml
default_config:
  admin_username: admin
  admin_password:  admin (oder auf Gerät aufgedruckt)
  management_ip: 192.168.1.1
  http_enabled: yes
  https_enabled: yes
  telnet_enabled: yes
  ssh_enabled: no
  wan_management:  enabled (UNSICHER!)
  upnp:  enabled
  firmware:  möglicherweise veraltet