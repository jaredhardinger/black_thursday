require_relative './sales_engine'
class SalesAnalyst
  attr_reader :item_repository, :merchant_repository, :invoice_repository, :invoice_item_repository

  def initialize(item_repository, merchant_repository, invoice_repository, invoice_item_repository, transaction_repository, customer_repository)
    @item_repository = item_repository
    @merchant_repository = merchant_repository
    @invoice_repository = invoice_repository
    @invoice_item_repository = invoice_item_repository
    @transaction_repository = transaction_repository
    @customer_repository = customer_repository
    @merchant_invoices = {}
  end

  def merchant_items_hash
    items_hash = @item_repository.all.group_by { |item| item.merchant_id }
    items_hash.map { |keys, values| items_hash[keys] = values.count }
    items_hash
  end

  def average_items_per_merchant
    number_of_merchants = merchant_items_hash.keys.count
    total_number_of_items = merchant_items_hash.values.sum
    average = (total_number_of_items.to_f / number_of_merchants)
    average.round(2)
  end

  def average_items_per_merchant_standard_deviation
    diff_squared = merchant_items_hash.values.map { |item_count| (item_count-average_items_per_merchant)**2 }
    std_dev = (diff_squared.sum / (diff_squared.count.to_f - 1))**0.5
    std_dev.round(2)
  end

  def merchants_with_high_item_count
    one_std_dev = average_items_per_merchant + average_items_per_merchant_standard_deviation
    top_merchants = merchant_items_hash.find_all { |keys, values| values > one_std_dev }
    top_merchant_array = top_merchants.map do |merchant|
      @merchant_repository.find_by_id(merchant[0])
    end
  end

  def average_item_price_for_merchant(merchant_id)
    merchant_items = @item_repository.all.find_all { |item| merchant_id == item.merchant_id }
    merchant_items = merchant_items.map { |item| item.unit_price }
    average = merchant_items.sum / merchant_items.count
    average.round(2)
  end

  def average_average_price_per_merchant
    merchants = merchant_items_hash.keys
    average = merchants.map { |merchant| average_item_price_for_merchant(merchant) }
    average_average = average.sum / average.count
    average_average.round(2)
  end

  def average_price_plus_two_standard_deviations
    prices = @item_repository.all.map { |item| item.unit_price }
    average = prices.sum / prices.count
    diff_squared = prices.map { |price| (price-average)**2 }
    std_dev = (diff_squared.sum / (diff_squared.count.to_f - 1))**0.5
    avg_plus_two_std_dev = average + 2 * std_dev
  end

  def golden_items
    top_items = @item_repository.all.find_all { |item| item.unit_price > average_price_plus_two_standard_deviations }
    top_items
  end

  def average_invoices_per_merchant
    number_of_merchants = merchant_items_hash.keys.count
    total_number_of_invoices = @invoice_repository.all.count
    average = (total_number_of_invoices.to_f / number_of_merchants)
    average.round(2)
  end

  def invoices_per_merchant
    @merchant_repository.all.map do |merchant|
      invoices = @invoice_repository.all.find_all { |invoice| invoice.merchant_id == merchant.id }
      @merchant_invoices[merchant.id] = invoices.count
    end
    @merchant_invoices
  end

  def average_invoices_per_merchant_standard_deviation
    diff_squared = invoices_per_merchant.values.map do |item_count|
      (item_count-average_invoices_per_merchant)**2
    end
    std_dev = (diff_squared.sum / (diff_squared.count.to_f - 1))**0.5
    std_dev.round(2)
  end

  def top_merchants_by_invoice_count
    sorted_merchants = invoices_per_merchant.sort_by{ |keys,values| -values }.to_h
    two_std_dev = average_invoices_per_merchant + 2 * average_invoices_per_merchant_standard_deviation
    top_merchants = sorted_merchants.find_all { |keys, values| values > two_std_dev }
    top_merchant_array = top_merchants.map do |merchant|
      @merchant_repository.find_by_id(merchant[0])
    end
  end

  def bottom_merchants_by_invoice_count
    sorted_merchants = invoices_per_merchant.sort_by{ |keys,values| -values }.to_h
    two_std_dev = average_invoices_per_merchant - 2 * average_invoices_per_merchant_standard_deviation
    bottom_merchants = sorted_merchants.find_all { |keys, values| values < two_std_dev }
    bottom_merchant_array = bottom_merchants.map do |merchant|
      @merchant_repository.find_by_id(merchant[0])
    end
  end

  def invoice_count_by_day
    dates = @invoice_repository.all.map { |invoice| invoice.created_at }
    days = dates.map { |date| date.strftime("%A") }
    days_count = Hash.new(0)
    days.each { |day| days_count[day] += 1 }
    days_count
  end

  def average_invoices_per_day_std_dev
    average = invoice_count_by_day.values.sum / 7
    diff_squared = invoice_count_by_day.values.map do |invoice_count|
      (invoice_count-average)**2
    end
    std_dev = (diff_squared.sum / (diff_squared.count.to_f - 1))**0.5
    std_dev.round(2) + average
  end

  def top_days_by_invoice_count
    top_days = invoice_count_by_day.find_all do |keys, values|
      values > average_invoices_per_day_std_dev
    end.to_h
    top_days.keys
  end

  def invoice_status(status)
    status_count = @invoice_repository.all.find_all do |invoice|
     status == invoice.status
    end.count
    percentage = status_count.to_f / @invoice_repository.all.count
    (percentage * 100).round(2)
  end

  def invoice_paid_in_full?(invoice_id)
    transactions = @transaction_repository.find_all_by_invoice_id(invoice_id)
    transactions.any? { |transaction| transaction.result == :success }
  end

  def invoice_total(invoice_id)
    invoice = @invoice_item_repository.find_all_by_invoice_id(invoice_id)
    invoice.sum { |item| item.unit_price * item.quantity }
  end

  def total_revenue_by_date(date)
    invoices_on_date = @invoice_repository.all.find_all { |invoice| invoice.created_at.to_s.include?(date.to_s.split(/ /, 3).first) }
    transactions_on_date = invoices_on_date.flat_map { |invoice| @transaction_repository.find_all_by_invoice_id(invoice.id) }
    successful = transactions_on_date.select { |transaction| transaction.result == :success }
    invoice_ids = successful.map { |transaction| transaction.invoice_id }.uniq
    invoices = invoice_ids.flat_map { |id| @invoice_item_repository.find_all_by_invoice_id(id) }
    total_rev = invoices.map { |item| item.unit_price_to_dollars * item.quantity }
    BigDecimal(total_rev.sum, 7)
  end

  def top_revenue_earners(number = 20)
    merchant_revenue = {}
    merchants = @merchant_repository.all.map { |merchant| merchant.id }
    merchants.each { |merchant| merchant_revenue[merchant] = revenue_by_merchant(merchant) }
    sorted = merchant_revenue.sort_by { |id, rev| -rev }
    top_x = sorted.first(number)
    top_x.map { |id, _rev| @merchant_repository.find_by_id(id) }
  end

  def merchants_with_pending_invoices
    inv_ids = @invoice_repository.all.map(&:id)
    inv_trans = {}
    inv_ids.each { |id| inv_trans[id] = @transaction_repository.find_all_by_invoice_id(id) }
    inv_trans.delete_if { |_id, trans| trans.any? { |tran| tran.result == :success } }
    un_invoices = inv_trans.keys.map { |inv_id| @invoice_repository.find_by_id(inv_id) }
    un_invoices.map { |inv| @merchant_repository.find_by_id(inv.merchant_id) }.uniq
  end

  def revenue_by_merchant(merchant_id)
    invoices = @invoice_repository.find_all_by_merchant_id(merchant_id)
    transactions = invoices.flat_map { |invoice| @transaction_repository.find_all_by_invoice_id(invoice.id) }
    successful = transactions.select { |transaction| transaction.result == :success }
    invoice_ids = successful.map { |transaction| transaction.invoice_id }.uniq
    invoices = invoice_ids.flat_map { |id| @invoice_item_repository.find_all_by_invoice_id(id) }
    total_rev = invoices.map { |item| item.unit_price_to_dollars * item.quantity }
    BigDecimal(total_rev.sum, 4)
  end

  def merchants_with_only_one_item
    merchant_items = @item_repository.all.group_by { |item| item.merchant_id }
    one_item_merchants = merchant_items.find_all do |merchant, items|
      items.count == 1
    end
    one_item_merchants.flat_map { |merchant, item| @merchant_repository.find_by_id(merchant) }
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_with_only_one_item.find_all do |merchant|
      Date.parse(merchant.created_at).strftime('%B') == month
    end
  end

  def most_sold_item_for_merchant(merchant_id)
    invoice_ids = successful_invoice_items(merchant_id)
    max_quantity = invoice_ids.max_by { |invoice_item| invoice_item.quantity }
    top = invoice_ids.find_all do |invoice_item|
      invoice_item.quantity == max_quantity.quantity
    end
    top.map do |invoice_item|
      item_repository.find_by_id(invoice_item.item_id)
    end
  end

  def best_item_for_merchant(merchant_id)
    invoice_ids = successful_invoice_items(merchant_id)
    priciest = invoice_ids.max_by { |item| item.unit_price_to_dollars * item.quantity }
    item_repository.find_by_id(priciest.item_id)
  end

  def successful_invoice_items(merchant_id)
    invoices = @invoice_repository.find_all_by_merchant_id(merchant_id)
    ids = invoices.map { |invoice| invoice.id }
    transactions = ids.flat_map { |id| @transaction_repository.find_all_by_invoice_id(id) }
    successful = transactions.select { |transaction| transaction.result == :success }
    invoice_ids = successful.map { |transaction| transaction.invoice_id }.uniq
    invoice_ids.flat_map { |id| @invoice_item_repository.find_all_by_invoice_id(id) }
  end
end
