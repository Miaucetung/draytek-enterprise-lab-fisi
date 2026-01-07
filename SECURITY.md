# Security Policy

## 🔒 Reporting Security Issues

If you discover a security vulnerability in this lab project, please report it responsibly:

**DO NOT** open a public GitHub issue for security vulnerabilities. 

Instead, please send an email to the repository maintainer or use GitHub's private security advisory feature. 

## ⚠️ What NOT to Commit

This is a training project, but security best practices still apply:

### NEVER commit: 
- ❌ Real passwords or credentials
- ❌ Private keys or certificates
- ❌ Pre-Shared Keys (PSKs) for VPNs
- ❌ RADIUS shared secrets
- ❌ LDAP bind passwords
- ❌ API keys or tokens
- ❌ Real public IP addresses
- ❌ Real MAC addresses
- ❌ Real serial numbers
- ❌ Production network configurations

### ALWAYS use:
- ✅ Placeholder values:  `PLACEHOLDER`, `CHANGE_ME`, `YOUR_PASSWORD_HERE`
- ✅ RFC 5737 documentation IPs:  192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24
- ✅ RFC 1918 private IPs: 192.168.0.0/16, 172.16.0.0/12, 10.0.0.0/8
- ✅ Example domains: example.com, example.net, example.org
- ✅ `.example` suffix files for templates

## 🛡️ Lab Security Best Practices

### Network Isolation

This lab environment should be isolated from production networks:

1. **Physical Separation** (Recommended)
   - Dedicated hardware not connected to production
   - Separate internet connection if testing WAN features

2. **VLAN Isolation** (Acceptable)
   - Dedicated VLAN in production network
   - Strict firewall rules preventing access to production
   - No bridging between lab and production VLANs

3. **Virtualization** (For Learning Only)
   - GNS3/EVE-NG environment
   - Isolated virtual networks
   - No connection to physical production network

### Router Security

- Change default admin password immediately
- Disable WAN management access
- Use HTTPS for management interface
- Enable management access restrictions (source IP filtering)
- Disable unnecessary services (UPnP, Telnet, etc.)
- Keep firmware up to date
- Regular configuration backups

### Wireless Security

- Never use WEP or open authentication
- Use WPA2 or WPA3
- Strong passphrases (minimum 16 characters)
- Disable WPS
- Enable SSID isolation for guest networks
- Regular password rotation for shared PSKs

### VPN Security

- Use strong encryption (AES-256)
- Use strong authentication (certificates preferred over PSK)
- Implement split tunneling carefully (understand security implications)
- Regular audit of VPN user accounts
- Monitor VPN logs for anomalies

### RADIUS/LDAP Security

- Use strong passwords for RADIUS users
- Protect RADIUS shared secret
- Use secure LDAP (LDAPS) with certificate validation when possible
- Implement account lockout policies
- Regular audit of authentication logs
- Service accounts should have minimal privileges

### Logging & Monitoring

- Enable comprehensive logging
- Secure syslog communication (TLS)
- Regular log review
- Alert on suspicious activities: 
  - Failed authentication attempts
  - Configuration changes
  - WAN failover events
  - Firewall rule violations

## 🔍 Security Checklist

Before sharing your lab configuration: 

- [ ] All passwords replaced with placeholders
- [ ] All PSKs/secrets removed or replaced
- [ ] No real IP addresses from production networks
- [ ] No real MAC addresses
- [ ] No certificates with real organization names
- [ ] No API keys or tokens
- [ ] Configuration export sanitized
- [ ] README updated with appropriate warnings

## 📚 Security Resources

- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [BSI IT-Grundschutz](https://www.bsi.bund.de/EN/Topics/ITGrundschutz/itgrundschutz_node.html)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

## 🎓 For IHK Documentation

When documenting security for IHK projects: 

1. **Risk Analysis**:  Identify threats specific to your network design
2. **Security Measures**: Document implemented countermeasures
3. **Testing**: Demonstrate security controls work as intended
4. **Compliance**: Reference relevant standards (BSI, ISO 27001, etc.)

## 📞 Contact

For security-related questions about this project, please open a discussion or contact the maintainer directly. 

---

**Remember: Security is not a product, it's a process.**