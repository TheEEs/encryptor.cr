require "spec"
require "../src/encryptor"
require "../src/decryptor"
require "../src/kdf"

if LibSodium.init < 0
  raise "Cannot initialize LibSodium"
end
