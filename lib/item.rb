require 'BigDecimal'
require 'time'

class Item
  attr_reader :id,
              :name,
              :description,
              :unit_price,
              :created_at,
              :updated_at,
              :merchant_id

  def initialize(attributes)
    @id          = attributes[:id].to_i
    @name        = attributes[:name]
    @description = attributes[:description]
    @unit_price  = BigDecimal(attributes[:unit_price], 4) / 100
    @created_at  = Time.parse(attributes[:created_at].to_s)
    @updated_at  = Time.parse(attributes[:updated_at].to_s)
    @merchant_id = attributes[:merchant_id].to_i
  end

  def unit_price_to_dollars
    @unit_price.to_f
  end

  def update(attributes)
    @name = attributes[:name] unless attributes[:name].nil?
    @description = attributes[:description] unless attributes[:description].nil?
    @unit_price = BigDecimal(attributes[:unit_price], 4) unless attributes[:unit_price].nil?
    @updated_at = Time.now
  end
end
