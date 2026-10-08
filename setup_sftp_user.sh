#!/bin/bash
# ==============================================================================
# Script: setup_sftp_user.sh
# Mo ta: Tu dong tao user sftp-user va gia lap tui log backup cho SFTP
# Khoa hoc: DevOps Fundamentals - Session 07 - Bai 1
# ==============================================================================

set -e

echo "=== [1/4] Kiem tra quyen superuser (root) ==="
if [ "$EUID" -ne 0 ]; then
  echo "Loi: Vui long chay script duoi quyen root hoac dung sudo!"
  exit 1
fi

echo "=== [2/4] Tao nguoi dung gioi han sftp-user ==="
if id "sftp-user" &>/dev/null; then
    echo "User sftp-user da ton tai."
else
    # Tao user sftp-user khong thuoc nhom sudo
    useradd -m -s /bin/bash sftp-user
    echo "sftp-user:SftpSecurePass2026!" | chpasswd
    echo "Da tao user sftp-user thanh cong voi mat khau bao mat."
fi

# Dam bao sftp-user KHONG thuoc nhom sudo hoac admin
gpasswd -d sftp-user sudo &>/dev/null || true
gpasswd -d sftp-user admin &>/dev/null || true

echo "=== [3/4] Tao thu muc log va tệp log gia lap ==="
mkdir -p /var/log/app-backup/
touch /var/log/app-backup/backup-check.log

# Ghi noi dung log gia lap
echo "Backup status: SUCCESS at $(date)" > /var/log/app-backup/backup-check.log
echo "Database dump: COMPLETED (size: 45MB)" >> /var/log/app-backup/backup-check.log
echo "System check: ALL SERVICES OPERATIONAL" >> /var/log/app-backup/backup-check.log

echo "=== [4/4] Phan quyen truy cap cho sftp-user ==="
# sftp-user thuoc group sftp-user, root la owner
chown -R root:sftp-user /var/log/app-backup
chmod 750 /var/log/app-backup
chmod 640 /var/log/app-backup/backup-check.log

echo "================================================="
echo "HOAN THANH CAU HINH BAN DAU FOR SFTP-USER"
echo "================================================="
echo "Kiem tra user:"
id sftp-user
echo ""
echo "Kiem tra quyen file log:"
ls -l /var/log/app-backup/backup-check.log
