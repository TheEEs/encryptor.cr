# Decrypts files encrypted with the Encryptor class
# Uses libsodium's AEAD ChaCha20-Poly1305 stream encryption
require "./lib/libsodium"
require "progress"

class Decryptor
  # Custom exception raised when decryption fails
  class DecryptionError < Exception; end

  # LibSodium constants for ChaCha20-Poly1305 stream encryption
  HEADER_SIZE = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_HEADERBYTES
  KEY_SIZE    = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_KEYBYTES
  OVERHEAD    = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_ABYTES

  # Initializes a new Decryptor instance
  # 
  # Args:
  #   passphrase: The password used to derive the decryption key
  #   file_size: Optional file size for progress bar calculation
  def initialize(@passphare : String, file_size : UInt64? = nil)
    @state = LibSodium::State.new
    @header = Bytes.new(HEADER_SIZE)
    @bar = ProgressBar.new
    if file_size.is_a? UInt64
      @bar = ProgressBar.new file_size
    end
  end

  # Decrypts an encrypted file and saves the decrypted content to output path
  #
  # Args:
  #   path: Path to the encrypted file
  #   output_path: Path where decrypted file will be saved
  def decrypt_file(path, output_path)
    File.open(path, "rb") do |input_file|
      File.open(output_path, "wb") do |output_file|
        self.decrypt_io input_file, output_file
      end
    end
  end

  # Decrypts data from input IO stream and writes to output IO stream
  # Handles encrypted stream format: chunk_size | salt | header | encrypted_chunks
  #
  # Args:
  #   input_io: Input IO stream containing encrypted data
  #   output_io: Output IO stream for decrypted data
  #
  # Raises:
  #   DecryptionError: If decryption fails or data format is invalid
  def decrypt_io(input_io : IO, output_io : IO)
    # Read the chunk size (first 8 bytes in little-endian format)
    chunk_size_bytes = Bytes.new(sizeof(UInt64))
    unless input_io.read(chunk_size_bytes) == sizeof(UInt64)
      raise "Unable to load encrypted data chunk size"
    end
    chunk_size = IO::ByteFormat::LittleEndian.decode(UInt64, chunk_size_bytes)
    
    # Prepare buffers for decryption
    input_buffer = Bytes.new(chunk_size + OVERHEAD)
    output_buffer = Bytes.new(chunk_size)
    
    # Read the salt used for key derivation
    salt = Bytes.new(KDF::SALT_BYTES)
    unless input_io.read(salt) == KDF::SALT_BYTES
      raise "Unable to load salt"
    end
    
    # Derive the encryption key from passphrase and salt
    key = KDF.generate_key(@passphare, salt)
    
    # Read the encryption header
    unless input_io.read(@header) == HEADER_SIZE
      raise "Unable to read header!"
    end
    
    # Initialize the stream decryption state
    unless LibSodium.init_pull(
             pointerof(@state),
             @header,
             key
           ) == 0
      raise "Decryptor initialization fails!"
    end
    
    # Decrypt the stream chunk by chunk
    first_pull = true
    loop do
      input_rb = input_io.read(input_buffer)
      
      # Handle special case for first chunk if it's incomplete
      if first_pull && input_rb != chunk_size
        input_io.seek(-input_rb, IO::Seek::Current)
        first_pull = false
        next
      end
      
      # Check if this is the last chunk
      next_byte = input_io.read_byte
      input_io.seek(-1, IO::Seek::Current)
      
      # Decrypt the current chunk
      res = LibSodium.pull(
        pointerof(@state),
        output_buffer,
        out plain_text_len,
        out tag,
        input_buffer,
        input_rb,
        nil, 0
      )
      
      raise DecryptionError.new("Decryption error!") if res == -1
      
      # Write the decrypted data to output
      output_io.write(output_buffer[0, plain_text_len])
      @bar.tick input_rb
      
      # Stop if reached end of file or final tag
      if next_byte.nil? || tag == LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_FINAL
        break
      end
    end
  end
end
