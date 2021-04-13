require 'base64'
require 'digest'
require 'openssl'
require 'aes'

module AesCrypt

  def self.encrypt(password, plain_text, previous = nil , card_token = nil , card_iv = nil)
    begin
    if previous
        cipher = OpenSSL::Cipher.new('AES-256-CBC')
        password = Digest::SHA256.digest(password)
        cipher.encrypt  # set cipher to be encryption mode
        cipher.key = password
        iv = OpenSSL::Cipher.new('AES-256-CBC').random_iv
        cipher.iv  = iv
        encrypted = ''
        encrypted << cipher.update(plain_text)
        encrypted << cipher.final
        AesCrypt.b64enc(iv) + AesCrypt.b64enc(encrypted)
    elsif card_token
        AES.encrypt(plain_text,password)
    elsif card_iv
      iv = AesCrypt.b64enc(ENV["FINGERPRINT_IV"])
      AES.encrypt(plain_text,"#{ENV['CARD_AES_KEY']}-#{ENV['AES_KEY']}",{iv: iv})
    else
        AES.encrypt(plain_text, ENV['AES_KEY'])
    end
    rescue => ex
      puts ex.message
      # SlackService.notify("While Encrypting : #{ex.message}")
    end
  end


  def self.decrypt(password, secretdata, previous = nil, key = nil , card_token = nil)
    begin
    if previous
        iv = secretdata[0...24]
        iv = Base64::decode64(iv)
        secretdata = secretdata[24..secretdata.length]
        secretdata = Base64::decode64(secretdata)
        decipher = OpenSSL::Cipher.new('aes-256-cbc')
        password = Digest::SHA256.digest(password)
        decipher.decrypt
        decipher.key = password
        decipher.iv = iv
        decipher.update(secretdata) + decipher.final
    elsif key
        AES.decrypt(secretdata, key)
    elsif card_token
        AES.decrypt(secretdata, password)
    else
        AES.decrypt(secretdata, ENV['AES_KEY'])
    end
    rescue => ex
      puts ex.message
      # SlackService.notify("While Decrypting : #{ex.message}")
    end
  end

   def self.encrypt_ee(password, plain_text)
     begin
     cipher = OpenSSL::Cipher.new('AES-256-CBC')
     password = Digest::SHA256.digest(password)
     cipher.encrypt  # set cipher to be encryption mode
     cipher.key = password
     iv = ENV["FINGERPRINT_IV"]
     cipher.iv  = iv
     encrypted = ''
     encrypted << cipher.update(plain_text)
     encrypted << cipher.final
     AesCrypt.b64enc(encrypted)
     rescue => ex
       # SlackService.notify("While Encrypting : #{ex.message}")
     end
   end


   def self.decrypt_dd(password, secretdata)
      begin
     iv = ENV["FINGERPRINT_IV"]
     secretdata = Base64::decode64(secretdata)
     decipher = OpenSSL::Cipher.new('aes-256-cbc')
     password = Digest::SHA256.digest(password)
     decipher.decrypt
     decipher.key = password
     decipher.iv = iv
     decipher.update(secretdata) + decipher.final
      rescue => ex
        # SlackService.notify("While Decrypting : #{ex.message}")
      end
   end

  def self.b64enc(data)
    Base64.encode64(data).gsub(/\n/, '')
  end

end
