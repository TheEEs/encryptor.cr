# encryptor.cr

Một chương trình dùng để mã hóa/giải mã tệp tin.

## Hướng dẫn cài đặt
###1. Build từ mã nguồn
Chương trình này được viết bằng Crystal phiên bản `1.18.2`. Mặc dù các phiên bản trước đó vẫn có thể sử dụng được. Hãy cài đặt Crystal trên máy tính Linux của bạn. Ở đây giả sử bạn đang sử dụng Alpine Linux.
###2. Cài đặt các gói liên quan
```bash
doas apk add libsodium-static
```
###3. Build
Check out Repos này và di chuyển vào thư mục được clone về máy tính:
```bash
git clone https://github.com/theees/encryptor.cr
cd encryptor.cr
```
Chạy lệnh build
```bash
shards install
shards build --static --release
```
Copy binary vào thư mục hệ thống
```bash
doas cp -f ./bin/encryptor /usr/local/bin
```
###4. Sử dụng
```text
██████ ▄▄  ▄▄  ▄▄▄▄ ▄▄▄▄  ▄▄ ▄▄ ▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄  ▄▄▄▄     ▄▄▄▄ ▄▄▄▄  
██▄▄   ███▄██ ██▀▀▀ ██▄█▄ ▀███▀ ██▄█▀  ██  ██▀██ ██▄█▄   ██▀▀▀ ██▄█▄ 
██▄▄▄▄ ██ ▀██ ▀████ ██ ██   █   ██     ██  ▀███▀ ██ ██ ▄ ▀████ ██ ██
  File encryptor v1.0.0
  Usage: encryptor [subcommand] [options]
    encrypt                          Read FILE and write encrypted data to STDOUT
    decrypt                          Read FILE and write decrypted data to STDOUT
    -h, --help                       Show this help

```
####4.1. Mã hóa file
```bash
encryptor encrypt -p [your_passphrase] -b [block_size_to_read] -i [file_need_to_be_encrypted] > [output_file]
```
####4.1. Giải mã file
```bash
encryptor decryptor -p [your_passphrase] -i [file_need_to_be_decrypted] > [output_file]
```

> **Lưu ý**: Bạn phải nhớ passphrase được sử dụng để mã hóa file. Nếu quên, bạn sẽ **không bao giờ** giải mã được file đó nữa.