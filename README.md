# encryptor.cr

**Vietnamese / Tiếng Việt:**

Một chương trình dùng để mã hóa/giải mã tệp tin.

**English:**

A program for encrypting and decrypting files.

---

## Hướng dẫn cài đặt / Installation Guide

**Vietnamese:**

> Bạn có thể tải về pre-build binary mới nhất tại [đây](https://github.com/theees/encryptor.cr/releases/latest), hoặc:

**English:**

> You can download the latest pre-built binary [here](https://github.com/theees/encryptor.cr/releases/latest), or:

### 1. Build từ mã nguồn / Build from Source

**Vietnamese:**

Chương trình này được viết bằng Crystal phiên bản `1.18.2`. Mặc dù các phiên bản trước đó vẫn có thể sử dụng được. Hãy cài đặt Crystal trên máy tính Linux của bạn. Ở đây giả sử bạn đang sử dụng Alpine Linux.

**English:**

This program is written in Crystal version `1.18.2`. Although earlier versions may still work. Please install Crystal on your Linux machine. This guide assumes you are using Alpine Linux.

### 2. Cài đặt các gói liên quan / Install Required Packages

```bash
doas apk add libsodium-static
```

### 3. Build

**Vietnamese:**

Check out Repos này và di chuyển vào thư mục được clone về máy tính:

**English:**

Clone this repository and navigate to the cloned directory:

```bash
git clone https://github.com/theees/encryptor.cr
cd encryptor.cr
```

**Vietnamese:**

Chạy lệnh build

**English:**

Run the build command

```bash
shards install
shards build --static --release
```

**Vietnamese:**

Copy binary vào thư mục hệ thống

**English:**

Copy the binary to the system directory

```bash
doas cp -f ./bin/encryptor /usr/local/bin
```

### 4. Sử dụng / Usage

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

#### 4.1. Mã hóa file / Encrypt a File

```bash
encryptor encrypt -p [your_passphrase] -b [block_size_to_read] -i [file_need_to_be_encrypted] > [output_file]
```

#### 4.2. Giải mã file / Decrypt a File

```bash
encryptor decrypt -p [your_passphrase] -i [file_need_to_be_decrypted] > [output_file]
```

**Vietnamese:**

> **Lưu ý**: Bạn phải nhớ passphrase được sử dụng để mã hóa file. Nếu quên, bạn sẽ **không bao giờ** giải mã được file đó nữa.

**English:**

> **Note**: You must remember the passphrase used to encrypt the file. If you forget it, you will **never** be able to decrypt that file again.