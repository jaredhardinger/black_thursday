require './lib/transaction'

RSpec.describe Transaction do
  before :each do
    @t = Transaction.new({
      :id => 6,
      :invoice_id => 8,
      :credit_card_number => "4242424242424242",
      :credit_card_expiration_date => "0220",
      :result => "success",
      :created_at => Time.now,
      :updated_at => Time.now
    })
  end

  it "exists" do
    expect(@t).to be_a(Transaction)
  end

end
