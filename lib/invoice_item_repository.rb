require 'csv'
require_relative 'invoice_item'
require_relative 'methodable'

class InvoiceItemRepository
  include Methodable
  attr_reader :all

  def initialize(filepath)
    @filepath = filepath
    @all = []
    CSV.foreach(@filepath, headers: true, header_converters: :symbol) do |row|
      @all << InvoiceItem.new(row)
    end
  end

  def find_all_by_item_id(item_id)
    @all.find_all { |invoiceitem| invoiceitem.item_id == item_id }
  end

  def find_all_by_invoice_id(invoice_id)
    @all.find_all { |invoiceitem| invoiceitem.invoice_id == invoice_id }
  end
end
