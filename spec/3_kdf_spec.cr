require "./spec_helper"

describe KDF do
  context "when deriver a key from password" do
    it "should work" do
      password = "asdfasdfasdfqwerqwdfasfawegf"
      salt = KDF.generate_salt
      key = KDF.generate_key password, salt
      key.bytesize.should eq Encryptor::KEY_SIZE
    end

    it "should generate base64 key of the salt" do
      password = "asdfasdfasdfqwerqwdfasfawegf"
      salt = KDF.generate_salt
      b64s = KDF.base64_encode(salt)
      b64s2 = KDF.base64_decode(b64s)
      b64s2.should eq salt
    end
  end
end
