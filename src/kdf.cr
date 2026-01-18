# Key Derivation Function (KDF) module
# Provides password-based key derivation using Argon2id hashing and base64 encoding utilities
require "base64"

module KDF
  # Argon2id password hashing parameters for moderate security level
  CRYPTO_PWHASH_OPSLIMIT_MODERATE =         3
  CRYPTO_PWHASH_MEMLIMIT_MODERATE = 268435456
  CRYPTO_PWHASH_ALG_DEFAULT       =         2
  # Salt size for Argon2id (from libsodium)
  SALT_BYTES                      = LibSodium::CRYPTO_PWHASH_ARGON2ID_SALTBYTES
  extend self

  # Generates a cryptographically secure random salt
  #
  # Returns:
  #   Bytes: A random salt of SALT_BYTES length
  def generate_salt : Bytes
    salt = Bytes.new(SALT_BYTES)
    Random::Secure.random_bytes salt
    salt
  end

  # Derives an encryption key from a password and salt using Argon2id
  #
  # Args:
  #   password: The user's password as a String
  #   salt: The salt bytes for key derivation
  #
  # Returns:
  #   Bytes: The derived encryption key (KEY_SIZE bytes)
  def generate_key(password : String, salt : Bytes) : Bytes
    key = Bytes.new(Encryptor::KEY_SIZE)
    byte_password = password.to_slice
    # Use Argon2id with moderate parameters for balanced security and performance
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

  # Encodes data to base64 format (strict RFC 4648 compliant)
  #
  # Args:
  #   data: The data to encode
  #
  # Returns:
  #   String: Base64-encoded string
  def base64_encode(data)
    Base64.strict_encode data
  end

  # Decodes base64-encoded data
  #
  # Args:
  #   data: Base64-encoded string
  #
  # Returns:
  #   Bytes: The decoded binary data
  def base64_decode(data)
    Base64.decode data
  end
end
