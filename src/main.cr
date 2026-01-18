# Main CLI entry point for the encryptor application
# Parses command-line arguments and routes to encrypt or decrypt operations
require "option_parser"
require "colorize"
require "./decryptor.cr"
require "./encryptor.cr"
require "./kdf.cr"
require "./cli/action.cr"

# Hash to store parsed command-line options
options = Hash(Symbol, Symbol | String | UInt64).new

# Setup command-line parser with subcommands and options
parser = OptionParser.new do |parser|
  logo =
    <<-logo
  ██████ ▄▄  ▄▄  ▄▄▄▄ ▄▄▄▄  ▄▄ ▄▄ ▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄  ▄▄▄▄     ▄▄▄▄ ▄▄▄▄  
  ██▄▄   ███▄██ ██▀▀▀ ██▄█▄ ▀███▀ ██▄█▀  ██  ██▀██ ██▄█▄   ██▀▀▀ ██▄█▄ 
  ██▄▄▄▄ ██ ▀██ ▀████ ██ ██   █   ██     ██  ▀███▀ ██ ██ ▄ ▀████ ██ ██
  logo
  logo = logo.colorize.fore(:green)
  parser.banner =
    <<-banner
  #{logo}
  #{"File encryptor v1.0.0".colorize.fore(:green)}
  Usage: encryptor [subcommand] [options]
  banner

  # Encrypt subcommand: encrypts a file and outputs encrypted data to STDOUT
  parser.on "encrypt", "Read FILE and write encrypted data to STDOUT" do
    options[:action] = :encrypt
    parser.on "-p", "--passphrase PASSPHRASE", "Your passphrase" do |passphrase|
      options[:passphrase] = passphrase
    end
    parser.on "-i", "--input FILE", "File to encrypt" do |file_path|
      options[:input_file_path] = file_path
    end
    parser.on "-b", "--bs BLOCK_SIZE", "Block size (in bytes) to encrypt for each iteration" do |block_size|
      options[:block_size] = block_size.to_u64
    rescue ArgumentError
      STDERR.puts "ERROR: you must supply a positive number to #{"-b".colorize.bold}".colorize.fore(:red)
      exit 1
    end
  end

  # Decrypt subcommand: decrypts a file and outputs plaintext to STDOUT
  parser.on "decrypt", "Read FILE and write decrypted data to STDOUT" do
    options[:action] = :decrypt
    parser.on "-p", "--passphrase PASSPHRASE", "Your passphrase" do |passphrase|
      options[:passphrase] = passphrase
    end
    parser.on "-i", "--input FILE", "File to decrypt" do |file_path|
      options[:input_file_path] = file_path
    end
  end

  # Error handlers for invalid options and missing values
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option.".colorize.fore :red
    exit(1)
  end

  parser.missing_option do |flag|
    STDERR.puts "Error: you must supply a value to #{flag.colorize.bold}".colorize.fore :red
    exit(1)
  end

  # Help option
  parser.on "-h", "--help", "Show this help" do
    STDERR.puts parser
    exit
  end
end

# Parse command-line arguments
parser.parse

# Route to appropriate action and validate required options
begin
  case options[:action]
  when :encrypt
    # Validate required flags for encryption
    error = false
    if options[:passphrase]?.nil?
      STDERR.puts "Error: you must supply a passphare with #{"-p".colorize.bold} flag".colorize.fore :red
      error = true
    end
    if options[:input_file_path]?.nil?
      STDERR.puts "Error: you must supply an input file path with #{"-i".colorize.bold} flag".colorize.fore :red
      error = true
    end
    # Set default block size if not provided
    options[:block_size] = 1024_u64 unless options[:block_size]?
    exit(1) if error
    encrypt(options)
  when :decrypt
    # Validate required flags for decryption
    error = false
    if options[:passphrase]?.nil?
      STDERR.puts "Error: you must supply a passphare with #{"-p".colorize.bold} flag".colorize.fore :red
      error = true
    end
    if options[:input_file_path]?.nil?
      STDERR.puts "Error: you must supply an input file path with #{"-i".colorize.bold} flag".colorize.fore :red
      error = true
    end
    exit(1) if error
    decrypt(options)
  else
    # Display help if no valid subcommand provided
    STDERR.puts parser
    exit 0
  end
rescue ex : KeyError
  # Handle missing subcommand
  if ARGV.any?
    STDERR.puts "Could not perform action #{ARGV.first.colorize.bold}".colorize.fore(:red)
    exit 1
  else
    STDERR.puts parser
    exit 0
  end
end
