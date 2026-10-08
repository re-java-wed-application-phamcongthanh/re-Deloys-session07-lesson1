# Báo Cáo Bài 1: Quản lý người dùng giới hạn và Truyền tải dữ liệu qua SFTP trên Windows

## 🎯 1. Mục Tiêu
- Tạo tài khoản người dùng hệ thống giới hạn (`sftp-user`) không thuộc nhóm đặc quyền `sudo`, chuyên trách cho việc truyền/nhận tệp tin an toàn qua SSH/SFTP.
- Thiết lập phân quyền thư mục nhật ký hệ thống `/var/log/app-backup/` để cấp quyền đọc tối thiểu cho người dùng `sftp-user`.
- Thực hành kết nối và truyền tải file log (`backup-check.log`) từ máy chủ Linux về máy tính Windows thông qua phần mềm **Bitvise SSH Client** / **WinSCP**.

---

## 📋 2. Quy Trình Thực Hiện (Step-by-Step Guide)

### Bước 1: Khởi tạo tài khoản người dùng giới hạn `sftp-user`
Chạy lệnh khởi tạo tài khoản trên máy chủ VPS Linux:
```bash
sudo adduser sftp-user
```
*(Đặt mật khẩu bảo mật mạnh cho tài khoản, ví dụ: `SftpSecurePass2026!`)*

Kiểm tra danh sách nhóm của user để đảm bảo `sftp-user` **KHÔNG** thuộc nhóm `sudo`:
```bash
id sftp-user
```

### Bước 2: Khởi tạo thư mục và tệp tin log giả lập
Tạo thư mục lưu trữ bản sao lưu log và tạo tệp tin `backup-check.log`:
```bash
sudo mkdir -p /var/log/app-backup/
sudo touch /var/log/app-backup/backup-check.log
sudo bash -c 'echo "Backup status: SUCCESS at $(date)" > /var/log/app-backup/backup-check.log'
sudo bash -c 'echo "Database dump: COMPLETED (size: 45MB)" >> /var/log/app-backup/backup-check.log'
sudo bash -c 'echo "System check: ALL SERVICES OPERATIONAL" >> /var/log/app-backup/backup-check.log'
```

### Bước 3: Cấu hình phân quyền đọc cho `sftp-user`
Gán quyền sở hữu thư mục cho `root:sftp-user` và phân quyền truy cập tối thiểu:
```bash
sudo chown -R root:sftp-user /var/log/app-backup
sudo chmod 750 /var/log/app-backup
sudo chmod 640 /var/log/app-backup/backup-check.log
```
- **Ý nghĩa phân quyền**:
  - `750` (`rwxr-x---`) trên `/var/log/app-backup`: Owner `root` có toàn quyền, Group `sftp-user` có quyền đọc và chuyển hướng thư mục (`r-x`), Others không có quyền.
  - `640` (`rw-r-----`) trên `backup-check.log`: Owner `root` đọc/ghi, Group `sftp-user` chỉ có quyền đọc (`r--`), Others không có quyền.

---

## 🖥️ 3. Kết Nối SFTP Client Trên Windows (Bitvise SSH Client / WinSCP)

### Hướng dẫn kết nối qua Bitvise SSH Client / WinSCP:
1. Mở phần mềm SFTP Client trên Windows (**Bitvise SSH Client** hoặc **WinSCP**).
2. Điền thông tin kết nối:
   - **Host / Server IP**: `<IP_CUA_VPS>` (Ví dụ: `103.x.x.x` hoặc `192.168.1.50`)
   - **Port**: `22` (SFTP tiêu chuẩn)
   - **Username**: `sftp-user`
   - **Authentication Method**: `Password`
   - **Password**: Nhập mật khẩu của `sftp-user`
3. Nhấp **Log in** / **Connect**.
4. Khi kết nối thành công:
   - Mở cửa sổ **SFTP / Remote Files** ở khung bên phải.
   - Truy cập vào đường dẫn: `/var/log/app-backup/`.
   - Tìm tệp `backup-check.log` và thực hiện kéo-thả (Drag & Drop) về thư mục máy tính cục bộ (Local Files) ở khung bên trái.

---

## ✅ 4. Kết Quả Kiểm Tra & Xác Minh (Verification)

### 4.1. Kiểm tra sự tồn tại của User và Quyền hạn Tệp tin trên VPS:
```bash
id sftp-user
ls -l /var/log/app-backup/backup-check.log
```

**Kết quả hiển thị trên VPS:**
```text
uid=1001(sftp-user) gid=1001(sftp-user) groups=1001(sftp-user)
-rw-r----- 1 root sftp-user 128 Oct  8 07:20 /var/log/app-backup/backup-check.log
```
> ✅ **Xác nhận**: `sftp-user` không có trong danh sách nhóm `sudo` (uid/gid 1001), tệp log có quyền `640` thuộc nhóm `sftp-user`.

---

### 4.2. Kiểm tra nội dung tệp tin đã tải về trên Windows:
Nội dung tệp `backup-check.log` sau khi mở trên Windows bằng Notepad/VSCode:
```text
Backup status: SUCCESS at Thu Oct  8 07:20:18 UTC 2026
Database dump: COMPLETED (size: 45MB)
System check: ALL SERVICES OPERATIONAL
```
> ✅ **Xác nhận**: Nội dung tệp tin tải về khớp 100% với tệp tin gốc trên máy chủ Linux VPS.

---

## 🔒 5. Đánh Giá Bảo Mật (Security Best Practices)
1. **Cô lập đặc quyền**: Tài khoản `sftp-user` không thể thực thi lệnh `sudo`, hạn chế nguy cơ bị leo leo quyền nếu tài khoản bị lộ.
2. **Quyền tối thiểu (Principle of Least Privilege)**: `sftp-user` chỉ có quyền đọc file log (`640`), không thể sửa đổi hoặc xóa file log của hệ thống.
3. **Mã hóa dữ liệu**: Giao thức SFTP truyền tải dữ liệu trên nền SSH (port 22), đảm bảo dữ liệu log được mã hóa trên đường truyền Internet.
