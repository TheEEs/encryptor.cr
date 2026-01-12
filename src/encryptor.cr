require "./lib/libsodium"
require "progress"

class Encryptor
  class EncryptionError < Exception; end

  HEADER_SIZE = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_HEADERBYTES
  KEY_SIZE    = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_KEYBYTES
  OVERHEAD    = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_ABYTES

  def initialize(passphare : String, @chunk_size : UInt64 = 1024, file_size : UInt64? = nil)
    @state = LibSodium::State.new
    @header = Bytes.new(HEADER_SIZE)
    @salt = KDF.generate_salt
    @key = KDF.generate_key(passphare, @salt)
    @bar = ProgressBar.new
    if file_size.is_a? UInt64
      @bar = ProgressBar.new file_size
    end
    unless LibSodium.init_push(
             pointerof(@state),
             @header,
             @key
           ) == 0
      raise "Encryptor initialization failed!"
    end
  end

  def self.gen_key
    key = Bytes.new(KEY_SIZE)
    LibSodium.keygen(key)
    key
  end

  def encrypt_file(path, output_path)
    STDERR.puts "Encrypting #{path}".colorize.fore(:green)
    File.open(path, "rb") do |input_file|
      File.open(output_path, "wb") do |output_file|
        self.encrypt_io(input_file, output_file)
      end
    end
  end

  def encrypt_io(input_io : IO, output_io : IO)
    input_buffer = Bytes.new(@chunk_size)
    output_buffer = Bytes.new(@chunk_size + OVERHEAD)
    size_bytes = Bytes.new(sizeof(UInt64))
    IO::ByteFormat::LittleEndian.encode(@chunk_size, size_bytes)
    output_io.write(size_bytes)
    output_io.write(@salt)
    output_io.write(@header)
    loop do
      input_rb = input_io.read(input_buffer).to_u64
      next_byte = input_io.read_byte
      input_io.seek(-1, IO::Seek::Current)
      tag = if next_byte
              LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_MESSAGE
            else
              LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_FINAL
            end
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
      output_io.write(output_buffer[0, actual_output_len])
      @bar.tick(input_rb)
      break unless next_byte
    end
  end
end
