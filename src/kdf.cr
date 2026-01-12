require "base64"

module KDF
  CRYPTO_PWHASH_OPSLIMIT_MODERATE =         3
  CRYPTO_PWHASH_MEMLIMIT_MODERATE = 268435456
  CRYPTO_PWHASH_ALG_DEFAULT       =         2
  SALT_BYTES                      = LibSodium::CRYPTO_PWHASH_ARGON2ID_SALTBYTES
  extend self

  def generate_salt : Bytes
    salt = Bytes.new(SALT_BYTES)
    Random::Secure.random_bytes salt
    salt
  end

  def generate_key(password : String, salt : Bytes) : Bytes
    key = Bytes.new(Encryptor::KEY_SIZE)
    byte_password = password.to_slice
    LibSodium.pwhash(
      key,
      key.bytesize.to_u64,
      byte_password,
      byte_password.bytesize.to_u64,
      salt,
      CRYPTO_PWHASH_OPSLIMIT_MODERATE,
      CRYPTO_PWHASH_MEMLIMIT_MODERATE,
      2
    )
    key
  end

  def base64_encode(data)
    Base64.strict_encode data
  end

  def base64_decode(data)
    Base64.decode data
  end
end
