# frozen_string_literal: true

require 'nokogiri'
require_relative '../helpers'

RSpec.describe 'Ruby Test Task' do
  it 'Should read fixtures, parse contents and use Accounts class methods' do
    fixture_accounts = File.read('spec/fixtures/demo.bank.accounts.html')

    accounts_instance = Accounts.new
    accounts_instance.instance_reset
    html = Nokogiri::HTML(fixture_accounts)
    table_data = html_table_data(html: html, row_css: 'cp-item')

    accounts_instance.add_accounts_from_table(table_data)

    test_account = '40817810200000055320'
    test_balance = 1_000_000
    test_currency = 'RUB'

    parsed_account = accounts_instance.get_accounts(account_name: test_account).first

    expect(parsed_account['name']).to eq test_account
    expect(parsed_account['balance']).to eq test_balance
    expect(parsed_account['currency']).to eq test_currency
  end

  it 'Should read fixtures, parse contents and use Transactions class methods' do
    fixture_transactions = File.read('spec/fixtures/demo.bank.transactions.html')

    test_account = '40817810200000055320'
    transactions_instance = Transactions.new
    transactions_instance.instance_reset
    html = Nokogiri::HTML(fixture_transactions)
    table_data_deposit = html_table_data(html: html, row_css: 'cp-income')
    table_data_withdraw = html_table_data(html: html, row_css: 'cp-transaction', row_css_exclude: 'cp-income')
    table_data = table_data_deposit.map { |item| ['deposit'].append(*item) } +
                 table_data_withdraw.map { |item| ['withdraw'].append(*item) }

    transactions_instance.add_transactions_from_table(test_account, table_data)

    parsed_transactions = transactions_instance.get_account_transactions(test_account)

    expect(parsed_transactions.length).to eq 5
  end
end
