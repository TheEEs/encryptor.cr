require "colorize"
require "base64"

def encrypt(options)
  passphrase = options[:passphrase].as(String)
  file_path = options[:input_file_path].to_s
  input_file = File.open(file_path, "rb")
  e = Encryptor.new passphrase, file_size: File.size(file_path).to_u64
  e.encrypt_io(input_file, STDOUT)
  input_file.close
  STDOUT.close
  exit 0
rescue ex : File::NotFoundError
  STDERR.puts "ERROR: #{ex.file} is not a valid file!".colorize.fore(:red).bold
  exit 1
rescue Encryptor::EncryptionError
  STDERR.puts "ERROR: could not encrypt file: #{file_path}".colorize.fore(:red).bold
  exit 1
end

def decrypt(options)
  passphrase = options[:passphrase].as(String)
  file_path = options[:input_file_path].to_s
  input_file = File.open(file_path, "rb")
  d = Decryptor.new passphrase, file_size: File.size(file_path).to_u64
  d.decrypt_io(input_file, STDOUT)
  input_file.close
  STDOUT.close
  exit 0
rescue ex : File::NotFoundError
  STDERR.puts "ERROR: #{ex.file} is not a valid file!".colorize.fore(:red).bold
  exit 1
rescue Decryptor::DecryptionError
  STDERR.puts "ERROR: could not decrypt file: #{file_path}".colorize.fore(:red).bold
  exit 1
end
