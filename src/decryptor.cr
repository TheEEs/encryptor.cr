require "./lib/libsodium"

class Decryptor
  HEADER_SIZE = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_HEADERBYTES
  KEY_SIZE    = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_KEYBYTES
  OVERHEAD    = LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_ABYTES

  def initialize(@key : Bytes)
    @state = LibSodium::State.new
    @header = Bytes.new(HEADER_SIZE)
  end

  def decrypt_file(path, output_path)
    File.open(path, "rb") do |input_file|
      File.open(output_path, "wb") do |output_file|
        self.decrypt_io input_file, output_file
      end
    end
  end

  def decrypt_io(input_io : IO, output_io : IO)
    input_buffer = Bytes.new(Encryptor::CHUNK_SIZE + OVERHEAD)
    output_buffer = Bytes.new(Encryptor::CHUNK_SIZE)
    unless input_io.read(@header) == HEADER_SIZE
      raise "Unable to read header!"
    end
    unless LibSodium.init_pull(
             pointerof(@state),
             @header,
             @key
           ) == 0
      raise "Decryptor initialization fails!"
    end
    loop do
      input_rb = input_io.read(input_buffer)
      next_byte = input_io.read_byte # used to check eof
      input_io.seek(-1, IO::Seek::Current)
      res = LibSodium.pull(
        pointerof(@state),
        output_buffer,
        out plain_text_len,
        out tag,
        input_buffer,
        input_rb,
        nil, 0
      )
      raise "Decryption error!" if res == -1
      output_io.write(output_buffer[0, plain_text_len])
      if next_byte.nil? || tag == LibSodium::CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_FINAL
        break
      end
    end
  end
end
