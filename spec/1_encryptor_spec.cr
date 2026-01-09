require "./spec_helper"

describe Encryptor do
  context "when encrypting file" do
    it "should generate output file with `.encrypted` extension" do
      key = Encryptor.gen_key
      encryptor = Encryptor.new key
      File.write("./spec/key", key)
      encryptor.encrypt_file "./spec/img.JPG", "./spec/img.JPG.encrypted"
      File.file?("./spec/img.JPG.encrypted").should be_true
    end
  end
end
