# lib_sodium.cr
@[Link("sodium")]
lib LibSodium
  # Constants (fetched from sodium headers, values may vary by version but these are standard)
  CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_KEYBYTES    = 32
  CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_HEADERBYTES = 24
  CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_ABYTES      = 17
  CRYPTO_PWHASH_ARGON2ID_SALTBYTES                  = 16

  # Tags for the stream state
  CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_MESSAGE = 0_u8
  CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_PUSH    = 1_u8
  CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_REKEY   = 2_u8
  CRYPTO_SECRETSTREAM_XCHACHA20POLY1305_TAG_FINAL   = 3_u8

  # State struct (opaque in usage, but we need to allocate space for it)
  # Ideally, we use the state pointer API if available, or allocate sufficient bytes.
  # The recommended way is using `crypto_secretstream_xchacha20poly1305_state` pointer.
  struct State
    opaque : UInt8[512] # Reserve enough space for internal state
  end

  # Library initialization
  fun init = sodium_init : Int32

  # Key generation
  fun keygen = crypto_secretstream_xchacha20poly1305_keygen(k : UInt8*)

  # Initialization of the encryption stream
  fun init_push = crypto_secretstream_xchacha20poly1305_init_push(
    state : State*,
    header : UInt8*,
    k : UInt8*,
  ) : Int32

  # Encryption push (chunk processing)
  fun push = crypto_secretstream_xchacha20poly1305_push(
    state : State*,
    c : UInt8*,       # Ciphertext output
    clen_p : UInt64*, # Pointer to store actual ciphertext length
    m : UInt8*,       # Message input
    mlen : UInt64,    # Message length
    ad : UInt8*,      # Additional data (optional, can be null)
    adlen : UInt64,   # Additional data length
    tag : UInt8,      # Tag (MESSAGE, PUSH, REKEY, FINAL)
  ) : Int32

  fun init_pull = crypto_secretstream_xchacha20poly1305_init_pull(
    state : State*,
    header : UInt8*,
    k : UInt8*,
  ) : Int32

  fun pull = crypto_secretstream_xchacha20poly1305_pull(
    state : State*,
    m : UInt8*,       # Plaintext output
    mlen_p : UInt64*, # Pointer to store actual plaintext length
    tag_p : UInt8*,   # Pointer to store the tag (detect FINAL, etc.)
    c : UInt8*,       # Ciphertext input
    clen : UInt64,    # Ciphertext length
    ad : UInt8*,      # Additional data (optional)
    adlen : UInt64,   # Additional data length
  ) : Int32

  fun pwhash = crypto_pwhash(
    out : UInt8*,
    outlen : UInt64,
    passwd : UInt8*,
    passwdlen : UInt64,
    salt : UInt8*,
    opslimit : UInt64,
    memlimit : UInt64, # size_t
    alg : Int32,
  ) : Int32
end
