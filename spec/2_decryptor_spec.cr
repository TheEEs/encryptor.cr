require "./spec_helper"

describe Decryptor do
  context "when decrypting file" do
    it "should see img.JPG.encrypted file" do
      File.file?("./spec/img.JPG.encrypted").should be_true
    end

    it "should decrypt test.txt.encrypted file and see that decrypted_test.txt has the same content with test.txt" do
      key = Bytes.new(Encryptor::KEY_SIZE)
      File.open("./spec/key", "rb") do |key_file|
        byte_read = key_file.read(key)
        byte_read.should eq Encryptor::KEY_SIZE
      end
      decryptor = Decryptor.new(key)
      decryptor.decrypt_file("./spec/img.JPG.encrypted", "./spec/decrypted_img.JPG")
      decrypted_file_content = File.read("./spec/decrypted_img.JPG")
      original_file_content = File.read("./spec/img.JPG")
      decrypted_file_content.should eq original_file_content
    end
  end
end
