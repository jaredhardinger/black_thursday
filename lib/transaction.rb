require 'time'

class Transaction
  attr_reader :id,
              :invoice_id,
              :credit_card_number,
              :credit_card_expiration_date,
              :result,
              :created_at,
              :updated_at

  def initialize(attributes)
    @id = attributes[:id].to_i
    @invoice_id = attributes[:invoice_id].to_i
    @credit_card_number = attributes[:credit_card_number]
    @credit_card_expiration_date = attributes[:credit_card_expiration_date]
    @result = attributes[:result].to_sym
    @created_at  = Time.parse(attributes[:created_at].to_s)
    @updated_at  = Time.parse(attributes[:updated_at].to_s)
  end

  def update(attributes)
    @credit_card_number = attributes[:credit_card_number] unless attributes[:credit_card_number].nil?
    @credit_card_expiration_date = attributes[:credit_card_expiration_date] unless attributes[:credit_card_expiration_date].nil?
    @result = attributes[:result].to_sym unless attributes[:result].nil?
    @updated_at = Time.now
  end

end
