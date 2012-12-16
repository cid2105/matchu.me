class Enumeration
  def Enumeration.add_item(key,value)
    @hash ||= {}
    @hash[key]=value
  end

  def Enumeration.const_missing(key)
    @hash[key]
  end   

  def Enumeration.each
    @hash.each {|key,value| yield(key,value)}
  end

  def Enumeration.values
    @hash.values || []
  end

  def Enumeration.keys
    @hash.keys || []
  end

  def Enumeration.[](key)
    @hash[key]
  end
end

class Constants < Enumeration
  
   ## setting the correct values for Facebook app ID and secret
    if Rails.env == 'development' || Rails.env == 'test'
      self.add_item(:FACEBOOK_APP_ID, '129343557224546')
      self.add_item(:FACEBOOK_SECRET, '858e13f5b97faafc8ab157e446f44096')
      self.add_item(:S3_CREDENTIALS, { :access_key_id => 'AKIAJYZIBAGBSV6V7H2A', :secret_access_key => '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', :bucket => 'stakd_dev' })
      self.add_item(:HOST, 'http://localhost:5000/')
    else
      # Production
      self.add_item(:FACEBOOK_APP_ID, '281924215243523')
      self.add_item(:FACEBOOK_SECRET, 'ba907877eccfdbd398237954040191d0')
      self.add_item(:S3_CREDENTIALS, { :access_key_id => 'AKIAJYZIBAGBSV6V7H2A', :secret_access_key => '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', :bucket => 'stakd_prod' })
      self.add_item(:HOST, 'http://www.stakd.com/')
    end

    #date methods (-1 removed leading zero from string)
    Date::DATE_FORMATS[:month_and_date] = "%B %-1d"
    
end
