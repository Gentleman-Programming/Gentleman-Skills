# VPS Hardening Distro Runbook

Use this reference only after applying the main skill's decision gates. Keep a rollback SSH session open during SSH and firewall changes.

## Package install

```bash
# Debian/Ubuntu
sudo apt update
sudo apt install -y ufw fail2ban wireguard libpam-google-authenticator

# RHEL/Rocky/Alma/Fedora
# On RHEL/Rocky/Alma, enable EPEL first if fail2ban or google-authenticator is unavailable.
sudo dnf install -y firewalld fail2ban wireguard-tools google-authenticator policycoreutils-python-utils
sudo systemctl enable --now firewalld
```

## MFA with PAM TOTP

```bash
google-authenticator
```

```text
# /etc/pam.d/sshd
auth required pam_google_authenticator.so
```

```sshconfig
# /etc/ssh/sshd_config.d/20-mfa.conf, or equivalent managed block
KbdInteractiveAuthentication yes
AuthenticationMethods publickey,keyboard-interactive
```

Avoid `nullok` in the final rule because it allows users without a TOTP secret to bypass MFA.

## VPN-only SSH transition

Run these only after WireGuard login to the server VPN address is verified.

```bash
# Debian/Ubuntu
sudo ufw delete allow 22/tcp
sudo ufw allow from 10.0.0.0/24 to any port 22 proto tcp comment "SSH via VPN only"
sudo ufw status verbose
```

```bash
# RHEL/Rocky/Alma/Fedora
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.0.0/24" port protocol="tcp" port="22" accept'
sudo firewall-cmd --reload
sudo firewall-cmd --list-rich-rules
```

## Docker, Trivy, and sysctl baseline

```yaml
services:
  app:
    image: example/app:1.2.3
    user: "10001:10001"
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
```

```bash
trivy image --severity HIGH,CRITICAL example/app:1.2.3
docker info --format '{{json .SecurityOptions}}'
sudo ss -tulpn
```

```conf
# /etc/sysctl.d/99-hardening.conf
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.tcp_syncookies = 1
```

## Verification checklist

| Task | Command or check |
|------|------------------|
| Detect distro | `. /etc/os-release; echo "$ID $ID_LIKE"` |
| Validate SSH config | `sudo sshd -t` |
| Check SSH service | `systemctl status ssh || systemctl status sshd` |
| Debian firewall | `sudo ufw status verbose` |
| RHEL firewall | `sudo firewall-cmd --list-all` |
| RHEL SELinux | `getenforce; sudo semanage port -l | grep ssh_port_t` |
| SSH logs | `journalctl -u ssh || journalctl -u sshd`; `/var/log/auth.log`; `/var/log/secure` |
| Fail2ban | `sudo fail2ban-client status sshd` |
| WireGuard | `sudo wg show` |
| Open ports | `sudo ss -tulpn` |
| Trivy scan | `trivy image --severity HIGH,CRITICAL <image>` |
