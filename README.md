# UoA Scripts

Scripts for connecting to ABI hpc/drives on macOS. Credentials are stored securely in Keychain.

## Setup

```bash
chmod +x mount_hpc.sh unmount_hpc.sh vpn.sh ssh_hpc.sh
```

### Enable Touch ID for sudo (one-time)

Allows using Touch ID instead of typing your Mac password for `sudo`:

```bash
sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
sudo sed -i '' 's/#auth/auth/' /etc/pam.d/sudo_local
```

This survives macOS updates.

### Shell Aliases

Add to `~/.zshrc`:

```bash
# UoA scripts
alias vpn="~/PhD/scripts/vpn.sh"
alias mount-hpc="~/PhD/scripts/mount_hpc.sh"
alias unmount-hpc="~/PhD/scripts/unmount_hpc.sh"
alias ssh-hpc="~/PhD/scripts/ssh_hpc.sh"
```

Then reload: `source ~/.zshrc`

Now you can

```
  - vpn --otp 123456    — connect to VPN
  - mount-hpc           — mount the HPC drive
  - unmount-hpc         — unmount the HPC drive
  - ssh-hpc             — SSH into HPC
```

## VPN

Connect via OpenFortiVPN with biometric/OTP authentication.

```bash
vpn --otp 123456
```

- First run prompts for your uni password and saves it to Keychain
- Subsequent runs pull the password automatically
- OTP is required every time (time-based)
- `sudo` uses Touch ID if enabled (see setup above)

### Remove Saved VPN Password

```bash
security delete-generic-password -a "knan475" -s "uoa-vpn"
```

## Mount HPC Drive

Mount the HPC network drive (`nas1.bioeng.auckland.ac.nz/hpc`).

```bash
mount-hpc
```

First run prompts for your uni password and saves it to Keychain. The drive mounts to `~/hpc`.

### Remove Saved HPC Password

```bash
security delete-generic-password -a "knan475" -s "uoa-nas1-hpc"
```

### Unmount

```bash
unmount-hpc
```

Falls back to a force unmount if the drive is busy.

## SSH into HPC

SSH into HPC machines or ABI desktops. Password is stored in Keychain (first run prompts and saves it).

```bash
# Default: connects to hpc7 (with VPN, no token needed)
ssh-hpc

# Specific HPC machine
ssh-hpc --hpc 2

# Specific machine by name
ssh-hpc --machine BN82300

# Without VPN: route through bioeng10 gateway (requires 2FA token)
ssh-hpc --gateway --otp 123456

# Enable X11 forwarding (for GUI apps)
ssh-hpc -x
```

- **With VPN**: just password, pulled from Keychain automatically
- **Without VPN (`--gateway`)**: requires `--otp`, sends `password:token` for 2FA

The `--gateway` flag uses `bioeng10.bioeng.auckland.ac.nz` as a jump host. No programs should be run on the gateway — it's only for connecting to internal machines.

### Remove Saved HPC SSH Password

```bash
security delete-generic-password -a "knan475" -s "uoa-hpc"
```
