require 'csv'
require_relative 'merchant'
require_relative 'methodable'

class MerchantRepository
  include Methodable
  attr_reader :all

  def initialize(filepath)
    @filepath = filepath
    @all = []
    CSV.foreach(@filepath, headers: true, header_converters: :symbol) do |row|
      @all << Merchant.new(row)
    end
  end

  def find_by_name(name)
    @all.find { |merchant| merchant.name.downcase == name.downcase }
  end

  def find_all_by_name(name)
    @all.find_all { |merchant| merchant.name.downcase.include?(name.downcase) }
  end
end
