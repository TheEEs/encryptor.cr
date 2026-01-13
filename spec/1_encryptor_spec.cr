require "./spec_helper"

describe Encryptor do
  context "when encrypting file" do
    it "should generate output file with `.encrypted` extension" do
      passphare = "passphare@123"
      encryptor = Encryptor.new passphare, 1024_u64 * 1024, file_size: File.size("./spec/img.JPG").to_u64
      encryptor.encrypt_file "./spec/img.JPG", "./spec/img.JPG.encrypted"
      File.file?("./spec/img.JPG.encrypted").should be_true
    end
  end
end
