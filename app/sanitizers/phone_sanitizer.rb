class PhoneSanitizer
  def self.sanitize(phone)
    phone.gsub!('(', '')
    phone.gsub!(')', '')
    phone.gsub!(' ', '')
    phone.gsub!('-', '')
    return phone
  end
end
