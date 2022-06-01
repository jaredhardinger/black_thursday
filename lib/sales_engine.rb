require_relative 'merchant_repository'

class SalesEngine
  attr_reader :merchant_repository, :item_repository

  def initialize(items_filepath, merchants_filepath)
    @item_repository = ItemRepository.new(items_filepath)
    @merchant_repository = MerchantRepository.new(merchants_filepath)
  end

  def self.from_csv(data)
    SalesEngine.new(data[:items], data[:merchants])
  end

end
