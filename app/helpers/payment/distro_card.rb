require 'time'
require 'date'

module Payment
  # A +Card+ object represents a physical credit/debit card, and is capable of validating the various
  # data associated with these.
  #
  # At the moment, the following card types are supported:
  #
  # * Visa
  # * MasterCard
  # * Discover
  # * American Express
  # * Diner's Club
  # * JCB
  #
  # == Example Usage
  #   cc = Card.new(
  #     :first_name         => 'Steve',
  #     :last_name          => 'Smith',
  #     :month              => '9',
  #     :year               => '2017',
  #     :number             => '4242424242424242',
  #     :cvv => '424'
  #     :debit => false  ---> (false means Credit & true means Debit)
  #   )
  #
  #   cc.validate # => will raise card validation errors
  #   cc.display_number # => XXXX-XXXX-XXXX-4242

  class DistroCard

    class << self
      # Inherited, but can be overridden w/o changing parent's value
      attr_accessor :require_cvv
      attr_accessor :require_name
      card_companies = ['Visa', 'Mastercard', 'American Express', 'Diners Club', 'JCB', 'Discover']
    end

    self.require_name = true
    self.require_cvv = false

    # Returns or sets the card type. @return [Boolean]
    attr_accessor :debit

    # Returns or sets the card number. @return [String]
    attr_reader :number
    attr_reader :fingerprint

    def number=(value)
      @number = (empty?(value) ? value : value.to_s.gsub(/[^\d]/, ''))
      @card_brand = brand(value)
    end

    # Returns or sets the expiry month for the card. @return [Integer]
    attr_reader :month

    attr_accessor :exp_date

    # Returns or sets the expiry year for the card. @return [Integer]
    attr_reader :year

    # Returns or sets the expiry year for the card. @return [Integer]
    attr_reader :card_brand

    # Returns or sets the first name of the card holder. @return [String]
    attr_accessor :first_name

    # Returns or sets the last name of the card holder. @return [String]
    attr_accessor :last_name

    # Returns or sets the card verification value.
    #
    # This attribute is optional but recommended. The verification value is
    # a {card security code}[http://en.wikipedia.org/wiki/Card_security_code]. If provided,
    # the gateway will attempt to validate the value.
    #
    # @return [String] the verification value
    attr_accessor :cvv

    attr_accessor :qc_token

    attr_accessor :name
    # Sets if the card requires a verification value. @return [Boolean]
    def require_cvv=(value)
      @require_cvv_set = true
      @require_cvv = value
    end

    # def encrypt
    #   encryption logic
    # end
    #
    # def decrypt
    #   decryption logic
    # end

    # Returns if this card needs a verification value.
    #
    # By default this returns the configured value from `CreditCard.require_cvv`,
    # but one can set a per instance requirement with `credit_card.require_cvv = false`.
    #
    # @return [Boolean]
    def requires_cvv?
      @require_cvv_set ||= false
      if @require_cvv_set
        @require_cvv
      else
        self.class.requires_cvv?
      end
    end

    # Provides proxy access to an expiry date object @return [ExpiryDate]
    def expiry_date
      Payment::ExpiryDate.new(@month, @year)
    end

    # Returns whether the card has expired. @return +true+ if the card has expired, +false+ otherwise
    def expired?
      expiry_date.expired?
    end

    # Returns whether either the +first_name+ or the +last_name+ attributes has been set.
    def name?
      first_name? || last_name?
    end

    # Returns whether the +first_name+ attribute has been set.
    def first_name?
      first_name.present?
    end

    # Returns whether the +last_name+ attribute has been set.
    def last_name?
      last_name.present?
    end

    # Returns the full name of the card holder. @return [String] the full name of the card holder
    def name
      "#{first_name} #{last_name}".strip
    end

    def name=(full_name)
      names = full_name.split
      self.last_name  = names.pop
      self.first_name = names.join(' ')
    end

    def fingerprint=(fingerprint)
      @fingerprint = fingerprint
    end

    %w(month year start_month start_year).each do |m|
      class_eval %(
        def #{m}=(v)
          @#{m} = case v
          when "", nil, 0
            nil
          else
            v.to_i
          end
        end
      )
    end

    def cvv?
      !@cvv.blank?
    end

    # Returns a display-friendly version of the card number.
    #
    # All but the last 4 numbers are replaced with an "X", and hyphens are
    # inserted in order to improve legibility.
    #
    # @example
    #   card = Card.new(:number => "2132542376824338")
    #   card.display_number  # "XXXX-XXXX-XXXX-4338"
    #
    # @return [String] a display-friendly version of the card number

    def display_number
      self.class.mask(number)
    end

    def first_digits
      self.class.first_digits(number)
    end

    def last4
      last_digits
    end

    # Validates the card details.
    #
    # Any validation errors are added to the {#errors} attribute.
    def validate
      empty_checks({
        :first_name => @first_name,
        :last_name => @last_name,
        :number => @number,
        :month => @month,
        :year => @year,
      })
      if cvv?
        unless valid_card_verification_value?(@cvv)
          raise CardValidationError.new "CardValidationError: CVV should be #{(card_verification_value_length(@card_brand))} digits"
        end
      elsif requires_cvv?
        raise CardValidationError.new "Missing Parameter: CVV is required!"
      end
      unless valid_number?
        raise CardValidationError.new "CardValidationError: #{@number} is not a valid credit/debit card number"
      end
      unless empty?(@card_brand)
        raise CardValidationError.new "CardValidationError: Brand is not supported" if @card_brand == 'unknown' && !Card.card_companies.include?(@card_brand)
      end
      unless valid_month? && valid_expiry_year?
        raise CardValidationError.new "CardValidationError: Can't process expired card"
      end
    end

    def initialize(attributes = {}, token = nil, key = nil)
      # super
      # validate
      if token.present?
        @qc_token = token
        @fingerprint = attributes[:fingerprint]
        anc = decryption("#{@fingerprint}-#{key}-#{ENV['CARD_AES_KEY']}",token)
        anc = JSON.parse(anc)
        @number = anc["number"]
        #@cvv = anc["cvv"]
        @month = anc["month"]
        @year = anc["year"]
        @name = anc["name"]
      else
        # @fingerprint = AESCrypt.encrypt("#{ENV['CARD-ENCRYPTER']}-#{ENV['SALTER']}", @number)
        @number = attributes[:number]
        @fingerprint = AesCrypt.encrypt("#{ENV['CARD_AES_KEY']}-#{ENV['AES_KEY']}", @number , nil , nil,true)
        @qc_token = encryption("#{@fingerprint}-#{key}-#{ENV['CARD_AES_KEY']}", attributes.to_json)
      end
    end

    def encrypt
      hash = ""
      @qc_token = hash
      # Code for encrypt
    end

    def decrypt(token, key)
      # Code for decrypt
    end

    def encryption(key, plain_text)
      encrypted = AesCrypt.encrypt(key, plain_text,nil,true)
      return encrypted
    end

    def decryption(key,cipher_text)
      decrypted = AesCrypt.decrypt(key, cipher_text , nil , nil , true)
      return decrypted
    end

    def self.requires_cvv?
      require_cvv
    end

    def self.requires_name?
      require_name
    end

    def valid_number?
      valid_card_number_length?(@number) &&
      valid_card_number_characters?(@number)
      # && valid_checksum?(@number)
    end

    def valid_month?
      (1..12).cover?(@month.to_i)
    end

    def credit_card?
      !@debit
    end

    def valid_expiry_year?
      (Time.now.year..Time.now.year + 20).include?(@year.to_i)
    end

    def first_digits
      @number.slice(0,6)
    end

    def last_digits
      return '' if @number.nil?
      @number.length <= 4 ? @number : @number.slice(-4..-1)
    end

    def mask
      "XXXX-XXXX-XXXX-#{last_digits}"
    end

    private

    def empty_checks(args)
      args.each do |name, value|
        if value.nil?
          raise CardValidationError.new "Card Details Missing: #{name} is required."
        end
      end
    end

    def brand(number)
      if number =~ /^4[0-9]{6,}$/
        return 'Visa'
      elsif number =~ /^5[1-5][0-9]{5,}|222[1-9][0-9]{3,}|22[3-9][0-9]{4,}|2[3-6][0-9]{5,}|27[01][0-9]{4,}|2720[0-9]{3,}$/
        return 'Mastercard'
      elsif number =~ /^3[47][0-9]{5,}$/
        return 'American Express'
      elsif number =~ /^3(?:0[0-5]|[68][0-9])[0-9]{4,}$/
        return 'Diners Club'
      elsif number =~ /^6(?:011|5[0-9]{2})[0-9]{3,}$/
        return 'Discover'
      elsif number =~ /^(?:2131|1800|35[0-9]{3})[0-9]{3,}$/
        return 'JCB'
      end
      return 'unknown'
    end

    # Credit card providers have 3 digit verification values
    # This isn't standardised, these are called various names such as
    # CVC, CVV, CID, CSC and more
    # See: http://en.wikipedia.org/wiki/Card_security_code
    # American Express is the exception with 4 digits
    #
    # Below are links from the card providers with their requirements
    # visa:             http://usa.visa.com/personal/security/3-digit-security-code.jsp
    # master:           http://www.mastercard.com/ca/merchant/en/getstarted/Anatomy_MasterCard.html
    # jcb:              http://www.jcbcard.com/security/info.html
    # diners_club:      http://www.dinersclub.com/assets/DinersClub_card_ID_features.pdf
    # discover:         https://www.discover.com/credit-cards/help-center/glossary.html
    # american_express: https://online.americanexpress.com/myca/fuidfyp/us/action?request_type=un_fuid&Face=en_US
    def valid_card_verification_value?(cvv)
      cvv.to_s =~ /^\d{#{card_verification_value_length(@card_brand)}}$/
    end

    def card_verification_value_length(brand)
      case brand
      when 'american_express'
        4
      else
        3
      end
    end

    def valid_card_number_length?(number)
      number.length >= 12
    end

    def valid_card_number_characters?(number)
      !number.match(/\D/)
    end

    ODD_LUHN_VALUE = {
      48 => 0,
      49 => 1,
      50 => 2,
      51 => 3,
      52 => 4,
      53 => 5,
      54 => 6,
      55 => 7,
      56 => 8,
      57 => 9,
      nil => 0
    }.freeze

    EVEN_LUHN_VALUE = {
      48 => 0, # 0 * 2
      49 => 2, # 1 * 2
      50 => 4, # 2 * 2
      51 => 6, # 3 * 2
      52 => 8, # 4 * 2
      53 => 1, # 5 * 2 - 9
      54 => 3, # 6 * 2 - 9
      55 => 5, # etc ...
      56 => 7,
      57 => 9,
    }.freeze

    # Checks the validity of a card number by use of the Luhn Algorithm.
    # Please see http://en.wikipedia.org/wiki/Luhn_algorithm for details.
    # This implementation is from the luhn_checksum gem, https://github.com/zendesk/luhn_checksum.
    def valid_checksum?(numbers) #:nodoc:
      sum = 0

      odd = true
      numbers.reverse.bytes.each do |number|
        if odd
          odd = false
          sum += ODD_LUHN_VALUE[number]
        else
          odd = true
          sum += EVEN_LUHN_VALUE[number]
        end
      end
      sum % 10 == 0
    end
  end
end
