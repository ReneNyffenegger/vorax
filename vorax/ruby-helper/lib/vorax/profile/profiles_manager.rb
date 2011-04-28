require 'base64'
require 'rexml/document'
begin
  require 'openssl'
rescue LoadError
  # just ignore if cannot be loaded. If the user
  # decides that he do not want to store his passwords
  # then it doesn't matter anyway. Otherwise, he will
  # receive errors within the subsequent calls.
end

include REXML

module Vorax

  # A secure password repository. All passwords are encrypted using RSA
  # algorithm. The private key is also protected by a password provided
  # by the user. This password is the master key of the repository.
  class ProfilesManager

    # The file name for the private key
    PRIVATE_KEY = 'id_rsa'
    # The file name for the public key
    PUBLIC_KEY = 'id_rsa.pub'
    # The file name for the repository file.
    REPOSITORY_FILE = 'profiles.xml'

    attr_reader :repository_xml, :unlocked

    # Creates a new repository. The config_dir is the directory
    # where the RSA keys are along with the configuration
    # file. 
    def initialize(config_dir)
      @config_dir = config_dir
      @unlocked = false
      if File.exists?("#@config_dir/#{REPOSITORY_FILE}")
        # the profiles.xml file already exists. Just load it.
        @repository_xml = Document.new(File.read("#{config_dir}/#{REPOSITORY_FILE}"))
      else
        # the profiles.xml file does not exists. Initialize an empty repository.
        @repository_xml = Document.new
        @repository_xml.add_element('profiles')
      end
    end

    # Set the master key for the secured repository.
    def master_password=(master_password)
      @master_password = master_password
      @private_key = OpenSSL::PKey::RSA.new(File.read("#@config_dir/#{PRIVATE_KEY}"), master_password)
      @public_key = OpenSSL::PKey::RSA.new(File.read("#@config_dir/#{PUBLIC_KEY}"))
      @unlocked = true
    end

    # Add the provided profile to the repository. The profile is actually
    # a key which usually consists of an user@db stuff. The provided password
    # is encrypted before being added. You can add a profile without a password
    # which means that, for this connection profile, the user will be
    # always asked for a password.
    def add(profile, password=nil, attributes={})
      profile_element = @repository_xml.root.elements["profile[@id='#{profile}']"] || @repository_xml.root.add_element('profile', { 'id' => profile })
      profile_element.add_attribute('password', encrypt(password))
      attributes.each_key { |k| profile_element.add_attribute(k.to_s, attributes[k]) }
    end

    # Remove the provided profile from the repository.
    def remove(profile)
      @repository_xml.root.delete_element("profile[@id='#{profile}']")
    end

    # Does the profile exists?
    def exists?(profile)
      @repository_xml.root.elements["profile[@id='#{profile}']"]
    end

    # Get the password for the provided profile.
    def password(profile)
      profile_element = @repository_xml.root.elements["profile[@id='#{profile}']"]
      if profile_element
        enc_passwd = profile_element.attributes['password']
        return decrypt(enc_passwd) if enc_passwd
      end
    end

    # Get an attribute value for the provided profile.
    def attribute(profile, attr)
      profile_element = @repository_xml.root.elements["profile[@id='#{profile}']"]
      if profile_element
        profile_element.attributes[attr]
      end
    end

    # Save the repository to disk.
    def save
      File.open("#{@config_dir}/#{REPOSITORY_FILE}", 'w') { |f| @repository_xml.write(f, 2) }
    end

    # Creates the password repository, secured by the provided
    # password. It overwrites any keys already generated within the
    # config_dir. All profiles from the old repository will be
    # lost.
    def self.create(config_dir, master_password)
      rsa_key = OpenSSL::PKey::RSA.new(2048)
      cipher =  OpenSSL::Cipher::Cipher.new('des3')
      private_key = rsa_key.to_pem(cipher, master_password)
      public_key = rsa_key.public_key.to_pem
      File.open("#{config_dir}/#{PRIVATE_KEY}", 'w') { |f| f.puts(private_key) }
      File.open("#{config_dir}/#{PUBLIC_KEY}", 'w') { |f| f.puts(public_key) }
    end

    # Was the password repository already initialized into the
    # provided directory?
    def self.initialized?(config_dir)
      File.exists?("#{config_dir}/#{PRIVATE_KEY}") && 
        File.exists?("#{config_dir}/#{PUBLIC_KEY}")
    end

    private

    # Encript the provided text. The result is packed in Base64
    def encrypt(text)
      Base64.encode64(@public_key.public_encrypt(text)).gsub(/\n/, "") if text
    end

    # Decrypt the provided text. The input should be in Base64
    def decrypt(text)
      @private_key.private_decrypt(Base64.decode64(text)) if text
    end

  end

end
