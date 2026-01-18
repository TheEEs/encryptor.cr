# CLI action handlers for encryption and decryption operations
# Processes command-line options and manages file I/O for encrypt/decrypt workflows
require "colorize"
require "base64"

# Encrypts a file from options and writes encrypted output to STDOUT
#
# Args:
#   options: Hash containing:
#     :passphrase - The password for key derivation
#     :input_file_path - Path to the file to encrypt
#     :block_size - Optional chunk size in bytes (default: 1024)
#
# Exits with:
#   0 - Success
#   1 - File not found or encryption error
def encrypt(options)
  passphrase = options[:passphrase].as(String)
  file_path = options[:input_file_path].to_s
  input_file = File.open(file_path, "rb")
  chunk_size = options[:block_size].as?(UInt64) || 1024_u64
  # Create encryptor with passphrase and chunk size, initialize progress bar with file size
  e = Encryptor.new passphrase, chunk_size, file_size: File.size(file_path).to_u64
  # Encrypt file content and write to standard output
  e.encrypt_io(input_file, STDOUT)
  input_file.close
  STDERR.puts ""
  STDOUT.close
  exit 0
rescue ex : File::NotFoundError
  STDERR.puts "ERROR: #{ex.file} is not a valid file!".colorize.fore(:red).bold
  exit 1
rescue Encryptor::EncryptionError
  STDERR.puts "ERROR: could not encrypt file: #{file_path}".colorize.fore(:red).bold
  exit 1
end

# Decrypts a file from options and writes decrypted output to STDOUT
#
# Args:
#   options: Hash containing:
#     :passphrase - The password used to derive the decryption key
#     :input_file_path - Path to the encrypted file
#
# Exits with:
#   0 - Success
#   1 - File not found or decryption error
def decrypt(options)
  passphrase = options[:passphrase].as(String)
  file_path = options[:input_file_path].to_s
  input_file = File.open(file_path, "rb")
  # Create decryptor with passphrase, initialize progress bar with file size
  d = Decryptor.new passphrase, file_size: File.size(file_path).to_u64
  # Decrypt file content and write to standard output
  d.decrypt_io(input_file, STDOUT)
  input_file.close
  STDERR.puts ""
  STDOUT.close
  exit 0
rescue ex : File::NotFoundError
  STDERR.puts "ERROR: #{ex.file} is not a valid file!".colorize.fore(:red).bold
  exit 1
rescue Decryptor::DecryptionError
  STDERR.puts "ERROR: could not decrypt file: #{file_path}".colorize.fore(:red).bold
  exit 1
end
