require "option_parser"
require "colorize"
require "./decryptor.cr"
require "./encryptor.cr"
require "./kdf.cr"
require "./cli/action.cr"

options = Hash(Symbol, Symbol | String | Bytes).new

parser = OptionParser.new do |parser|
  parser.banner = <<-banner
    #{"File encryptor v1.0.0".colorize.fore(:green)}
    Usage: encryptor [subcommand] [options]
  banner

  parser.on "base64-encode", "Base64 encode data from STDIN and write to STDOUT" do
    options[:action] = :base64_encode
  end

  parser.on "base64-decode", "Base64 decode data from STDIN and write to STDOUT" do
    options[:action] = :base64_decode
  end

  parser.on "gen-salt", "Generate a salt for password-based key derivation" do
    options[:action] = :gen_salt
  end

  parser.on "gen-key", "Read a salt from STDIN and generate a key with provided passphare" do
    options[:action] = :gen_key
    parser.on "-p", "--passphrase PASSPHRASE", "Your passphrase" do |passphrase|
      options[:passphrase] = passphrase
    end
  end

  parser.on "encrypt", "Read FILE and write encrypted data to STDOUT" do
    options[:action] = :encrypt
    parser.on "-k", "--key KEY", "File contain key for encryption and decryption" do |key_path|
      key = Bytes.new(Encryptor::KEY_SIZE)
      File.open(key_path, "rb") do |file|
        file.read(key)
        options[:key] = key
      end
    end
    parser.on "-i", "--input FILE", "File used for encryption" do |file_path|
      options[:input_file_path] = file_path
    end
  end

  parser.on "decrypt", "Read FILE and write decrypted data to STDOUT" do
    options[:action] = :decrypt
    parser.on "-k", "--key KEY", "File contain key for encryption and decryption" do |key_path|
      key = Bytes.new(Encryptor::KEY_SIZE)
      File.open(key_path, "rb") do |file|
        file.read(key)
        options[:key] = key
      end
    end
    parser.on "-i", "--input FILE", "File used for decryption" do |file_path|
      options[:input_file_path] = file_path
    end
  end
  parser.on "-h", "--help", "Show this help" do
    puts parser
    exit
  end
end

parser.parse
case options[:action]
when :gen_salt
  gen_salt(options)
when :gen_key
  gen_key(options)
when :base64_encode
  base64_encode
when :base64_decode
  base64_decode
when :encrypt
  encrypt(options)
when :decrypt
  decrypt(options)
else
  puts parser
  exit 0
end
