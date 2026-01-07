# Security Baseline

## Übersicht

Dieses Dokument definiert die Sicherheits-Grundkonfiguration (Security Baseline) für die DrayTek Enterprise Lab-Umgebung.  Alle Labs sollten auf dieser Baseline aufbauen.

## Sicherheitsprinzipien

### Defense in Depth (Verteidigung in der Tiefe)

Mehrschichtige Sicherheit statt einzelner Maßnahmen:

1. **Perimeter Security**:  Firewall, IPS
2. **Network Segmentation**: VLANs, Security Zones
3. **Access Control**: Authentication, Authorization
4. **Monitoring**: Logging, Alerting
5. **Incident Response**: Detection, Mitigation

### Least Privilege (Minimale Rechte)

- Benutzer/Services erhalten nur minimal benötigte Rechte
- Default Deny Firewall-Policy
- Explizite Allow-Regeln nur wo nötig

### Zero Trust

- "Vertraue niemals, prüfe immer"
- Auch interne Verbindungen authentifizieren
- Segmentierung auch innerhalb des LANs

### Security by Design

- Sicherheit von Anfang an einplanen
- Nicht nachträglich "dazubauen"
- Regelmäßige Security-Reviews

## Router-Härtung

### 1. Admin-Zugang sichern

#### Starkes Admin-Passwort

**Anforderungen:**
- Mindestens 16 Zeichen
- Groß-/Kleinbuchstaben, Zahlen, Sonderzeichen
- Kein Wörterbuch-Wort
- Nicht wiederverwendet
- Nicht "admin", "password", "12345678"

**Empfehlung:**