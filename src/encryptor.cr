# Encrypts files using libsodium's AEAD ChaCha20-Poly1305 stream encryption
# Supports password-based key derivation and chunked encryption for large files
require "./lib/libsodium"
require "progress"

class Encryptor
  # Custom exception raised when encryption fails
  class EncryptionError < Exception; end

  # LibSodium constants for ChaCha20-Poly1305 stream encryption
  HEADER_SIZE = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_HEADERBYTES
  KEY_SIZE    = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_KEYBYTES
  OVERHEAD    = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_ABYTES

  # Initializes a new Encryptor instance
  #
  # Args:
  #   passphare: The password to derive the encryption key from
  #   chunk_size: Size of data chunks to encrypt at once (default: 1024 bytes)
  #   file_size: Optional file size for progress bar calculation
  #
  # Raises:
  #   If LibSodium initialization fails
  def initialize(passphare : String, @chunk_size : UInt64 = 1024, file_size : UInt64? = nil)
    @state = LibSodium::State.new
    @header = Bytes.new(HEADER_SIZE)
    # Generate random salt for key derivation
    @salt = KDF.generate_salt
    # Derive encryption key from password and salt
    @key = KDF.generate_key(passphare, @salt)
    @bar = ProgressBar.new
    if file_size.is_a? UInt64
      @bar = ProgressBar.new file_size
    end
    # Initialize the stream encryption state
    unless LibSodium.init_push(
             pointerof(@state),
             @header,
             @key
           ) == 0
      raise "Encryptor initialization failed!"
    end
  end

  # Generates a random encryption key
  #
  # Returns:
  #   Bytes: A cryptographically secure random key
  def self.gen_key
    key = Bytes.new(KEY_SIZE)
    LibSodium.keygen(key)
    key
  end

  # Encrypts a file and saves the encrypted output to a new file
  #
  # Args:
  #   path: Path to the plaintext file to encrypt
  #   output_path: Path where the encrypted file will be saved
  def encrypt_file(path, output_path)
    STDERR.puts "Encrypting #{path}".colorize.fore(:green)
    File.open(path, "rb") do |input_file|
      File.open(output_path, "wb") do |output_file|
        self.encrypt_io(input_file, output_file)
      end
    end
  end

  # Encrypts data from input IO stream and writes encrypted data to output IO stream
  # Writes format: chunk_size | salt | header | encrypted_chunks
  #
  # Args:
  #   input_io: Input IO stream containing plaintext data
  #   output_io: Output IO stream for encrypted data
  #
  # Raises:
  #   EncryptionError: If encryption fails
  def encrypt_io(input_io : IO, output_io : IO)
    input_buffer = Bytes.new(@chunk_size)
    output_buffer = Bytes.new(@chunk_size + OVERHEAD)
    
    # Write the chunk size in little-endian format
    size_bytes = Bytes.new(sizeof(UInt64))
    IO::ByteFormat::LittleEndian.encode(@chunk_size, size_bytes)
    output_io.write(size_bytes)
    
    # Write the salt needed for decryption key derivation
    output_io.write(@salt)
    # Write the encryption header
    output_io.write(@header)
    
    # Encrypt the data in chunks
    loop do
      input_rb = input_io.read(input_buffer).to_u64
      next_byte = input_io.read_byte
      input_io.seek(-1, IO::Seek::Current)
      
      # Set tag to FINAL if this is the last chunk
      tag = if next_byte
              LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_MESSAGE
            else
              LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_FINAL
            end
      
      # Encrypt the current chunk
      res = LibSodium.push(
        pointerof(@state),
        output_buffer,
        out actual_output_len,
        input_buffer,
        input_rb,
        nil, 0,
        tag
      )
      raise EncryptionError.new("Encryption error!") unless res == 0
      
      # Write the encrypted chunk to output
      output_io.write(output_buffer[0, actual_output_len])
      @bar.tick(input_rb)
      
      # Stop if reached end of file
      break unless next_byte
    end
  end
end
