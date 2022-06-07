require './lib/transaction_repository'

RSpec.describe TransactionRepository do
  before :each do
    @tr = TransactionRepository.new('./data/transactions.csv')

    @test_transaction = {
      :id => 6,
      :invoice_id => 8,
      :credit_card_number => "4242424242424242",
      :credit_card_expiration_date => "0220",
      :result => "success",
      :created_at => Time.now,
      :updated_at => Time.now
    }
  end

  it "exists" do
    expect(@tr).to be_a(TransactionRepository)
  end

  it "has all" do
    expect(@tr.all).to be_a(Array)
    expect(@tr.all).to include(Transaction)
  end

  it "can find_by_id" do
    expect(@tr.find_by_id(1)).to be_a(Transaction)
    expect(@tr.find_by_id(4986)).to be_nil
  end

  it "can find_all_by_invoice_id" do
    expect(@tr.find_all_by_invoice_id(2179)).to be_a(Array)
    expect(@tr.find_all_by_invoice_id(2179).length).to eq(2)
  end

  it "can find_all_by_credit_card_number" do
    expect(@tr.find_all_by_credit_card_number("4068631943231473")).to be_a(Array)
    expect(@tr.find_all_by_credit_card_number("4068631943231473").length).to eq(1)
  end

  it "can find_all_by_result" do
    expect(@tr.find_all_by_result(:success)).to be_a(Array)
    expect(@tr.find_all_by_result(:success).length).to eq(4158)
  end

  it "can create new transactions" do
    expect(@tr.find_by_id(4986)).to be_nil
    @tr.create(@test_transaction)
    expect(@tr.find_by_id(4986)).to be_a(Transaction)
    expect(@tr.find_by_id(4986).invoice_id).to eq(8)
  end

  it "can update transactions" do
    @tr.create(@test_transaction)
    expect(@tr.find_by_id(4986)).to be_a(Transaction)
    expect(@tr.find_by_id(4986).credit_card_number).to eq("4242424242424242")
    expect(@tr.find_by_id(4986).credit_card_expiration_date).to eq("0220")
    expect(@tr.find_by_id(4986).result).to eq(:success)
    @tr.update(4986, {credit_card_number: "4242424242424243", credit_card_expiration_date: "0221", result: "failed"})
    expect(@tr.find_by_id(4986)).to be_a(Transaction)
    expect(@tr.find_by_id(4986).credit_card_number).to eq("4242424242424243")
    expect(@tr.find_by_id(4986).credit_card_expiration_date).to eq("0221")
    expect(@tr.find_by_id(4986).result).to eq(:failed)
  end

  it "has delete(id)" do
    @tr.create(@test_transaction)
    expect(@tr.find_by_id(4986).invoice_id).to eq(8)
    @tr.delete(4986)
    expect(@tr.find_by_id(4986)).to be_nil
  end

end
