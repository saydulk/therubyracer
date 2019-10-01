module Private::IdDocumentHelper
  include CountryCodes

  def contact_no_without_code(contact_no, code)
    return if contact_no.nil?
    country_detail = country_specific_code(code)
    country_code = country_detail[:dial_code] unless country_detail.nil?
    country_code.present? ? contact_no.gsub("#{country_code.to_s}", '') : ''
  end
end
