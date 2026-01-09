require "colorize"
require "base64"

def gen_salt(options)
  salt = KDF.generate_salt
  STDOUT.write(salt)
  exit 0
end

def base64_decode
  data = STDIN.getb_to_end
  Base64.decode(data, STDOUT)
  exit 0
end

def base64_encode
  data = STDIN.getb_to_end
  Base64.strict_encode(data, STDOUT)
  exit 0
end

def gen_key(options)
  passphare = options[:passphrase].to_s
  raise "You cannot provide an empty passphrase" if passphare.empty?
  salt_bytes = STDIN.getb_to_end
  raise "Invalid salt" unless salt_bytes.bytesize == LibSodium::CRYPTO_PWHASH_ARGON2ID_SALTBYTES
  STDOUT.write KDF.generate_key(passphare, salt_bytes)
  exit 0
end

def encrypt(options)
  key_path = options[:key_path].to_s
  raise "Invalid key path" unless File.file? key_path
  file_path = options[:input_file_path].to_s
  raise "Invalid file path" unless File.file? file_path
  key = Bytes.new(Encryptor::KEY_SIZE)
  File.open(key_path, "rb") do |file|
    file.read(key)
  end
  input_file = File.open(file_path, "rb")
  e = Encryptor.new key
  e.encrypt_io(input_file, STDOUT)
  input_file.close
  STDOUT.close
  exit 0
end

def decrypt(options)
  key_path = options[:key_path].to_s
  raise "Invalid key path" unless File.file? key_path
  file_path = options[:input_file_path].to_s
  raise "Invalid file path" unless File.file? file_path
  key = Bytes.new(Encryptor::KEY_SIZE)
  File.open(key_path, "rb") do |file|
    file.read(key)
  end
  input_file = File.open(file_path, "rb")
  d = Decryptor.new key
  d.decrypt_io(input_file, STDOUT)
  input_file.close
  STDOUT.close
  exit 0
end
