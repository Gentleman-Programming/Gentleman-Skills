---
name: vps-hardening
description: "Trigger: Harden Linux VPS servers with distro-aware SSH, firewall, VPN, Fail2ban, Docker, sysctl, and SELinux guidance."
license: MIT
metadata:
  author: constant1n0
  version: "1.0"
---

## Activation Contract

Use this skill when hardening or auditing a Linux VPS on Debian/Ubuntu or RHEL-family systems, especially for SSH, MFA, firewall policy, Fail2ban, WireGuard, Docker security, sysctl, or SELinux.

## Critical Patterns

- Detect the distro family before writing commands; never assume Debian defaults.
- Keep a root/sudo rollback session open while changing SSH or firewall access.
- Validate `sshd` syntax and test a fresh login before closing the rollback session.
- On RHEL/Rocky/Alma/Fedora, keep SELinux enforcing when possible; fix labels, ports, and booleans instead of disabling it.
- Do not hide security transition failures with `|| true`.
- Move public SSH behind VPN only after WireGuard and replacement firewall access are verified.

## Decision Gates

| Need | Debian/Ubuntu | RHEL/Rocky/Alma/Fedora |
|------|---------------|-------------------------|
| Packages | `apt` | `dnf`; enable EPEL if packages are missing |
| Firewall | `ufw` | `firewalld` |
| SSH service | `ssh` or `sshd` | `sshd` |
| SSH auth logs | `/var/log/auth.log` or `journalctl` | `journalctl`; `/var/log/secure` only when rsyslog writes it |
| Fail2ban action | `ufw` | `firewallcmd-rich-rules` or `firewallcmd-ipset` |
| Extra safety check | Confirm UFW default deny keeps SSH reachable | Confirm SELinux port labels before SSH restart |

## Execution Steps

1. Detect distro family and current SSH/firewall state.
2. Install only family-appropriate packages.
3. Apply SSH key-only baseline; validate with `sshd -t`; test a new login.
4. Configure the native firewall while preserving current SSH access.
5. Add Fail2ban and MFA; verify logs and authentication flow.
6. Configure WireGuard; verify VPN reachability.
7. Restrict SSH to VPN/admin allowlist with branch-specific firewall commands.
8. Apply Docker, Trivy, and sysctl checks; capture verification evidence.

## Code Examples

### Example 1: Detect distro before commands

```bash
. /etc/os-release
case "$ID:$ID_LIKE" in
  *debian*|*ubuntu*) family=debian ;;
  *rhel*|*fedora*|*centos*) family=redhat ;;
  *) echo "Unsupported distro family: $ID $ID_LIKE" >&2; exit 1 ;;
esac
```

### Example 2: SSH baseline with rollback session

```sshconfig
# /etc/ssh/sshd_config.d/10-hardening.conf, or equivalent managed block
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
AllowUsers admin deploy
```

```bash
sudo sshd -t
sudo systemctl restart ssh || sudo systemctl restart sshd
ssh -o PreferredAuthentications=publickey admin@server.example.com
```

### Example 3: Firewall branch must match distro

```bash
# Debian/Ubuntu
sudo ufw allow 22/tcp comment "SSH"
sudo ufw allow 51820/udp comment "WireGuard"
sudo ufw enable
sudo ufw status verbose
```

```bash
# RHEL/Rocky/Alma/Fedora
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-port=51820/udp
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

### Example 4: RHEL custom SSH port stages access before removal

```bash
new_port=2222
sudo semanage port -a -t ssh_port_t -p tcp "$new_port" || sudo semanage port -m -t ssh_port_t -p tcp "$new_port"
sudo firewall-cmd --permanent --add-port="$new_port"/tcp
sudo firewall-cmd --reload
sudo sshd -t
sudo systemctl restart sshd
ssh -p "$new_port" admin@server.example.com
# Only after the new login succeeds: remove old public SSH access.
```

### Example 5: Fail2ban backend differs by family

```ini
# Debian/Ubuntu
[sshd]
enabled = true
banaction = ufw
logpath = /var/log/auth.log
```

```ini
# RHEL/Rocky/Alma/Fedora
[sshd]
enabled = true
banaction = firewallcmd-rich-rules
backend = systemd
```

## Anti-Patterns

- Enabling default-deny before allowing and testing SSH.
- Removing old SSH firewall access before proving the replacement login works.
- Disabling SELinux instead of fixing labels, booleans, or port contexts.
- Copying Debian-only values such as `banaction = ufw` or `/var/log/auth.log` to RHEL-family systems.
- Using `nullok` as the final PAM MFA rule; users without a TOTP secret would bypass MFA.
- Hiding failed firewall changes with `|| true` during public SSH restriction.

## Output Contract

Return the detected distro family, selected firewall, SSH service name, commands changed, verification evidence, and any rollback step that remains open.

## References

- `references/distro-runbook.md` — detailed distro-specific command examples for MFA, VPN-only SSH, Docker/Trivy, and sysctl verification.
