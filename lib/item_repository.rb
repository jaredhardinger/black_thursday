require 'csv'
require_relative 'item'
require_relative 'methodable'

class ItemRepository
  include Methodable
  attr_reader :all

  def initialize(filepath)
    @filepath = filepath
    @all = []
    CSV.foreach(@filepath, headers: true, header_converters: :symbol) do |row|
      @all << Item.new(row)
    end
  end

  def find_by_name(name)
    @all.find { |item| item.name.downcase == name.downcase }
  end

  def find_all_with_description(description)
    @all.find_all { |item| item.description.downcase.include?(description.downcase) }
  end

  def find_all_by_price(price)
    @all.find_all { |item| item.unit_price == price }
  end

  def find_all_by_price_in_range(range)
    range_array = []
    @all.each do |item|
      if item.unit_price_to_dollars >= range.first && item.unit_price_to_dollars <= range.last
        range_array << item
      end
    end
    range_array.uniq
  end

  def find_all_by_merchant_id(merchant_id)
    @all.find_all { |item| item.merchant_id == merchant_id }
  end
end
