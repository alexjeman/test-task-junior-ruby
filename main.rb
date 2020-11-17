require 'watir'
require_relative 'helpers'

# Scraper control class, all Accounts and Transactions methods are accessed through this class
class Scraper
  attr_accessor :browser, :login, :password, :account_data, :transaction_data

  def initialize(**kwargs)
    # Init browser driver, as argument or default :chrome
    # Init Accounts instance - accounts class for managing account_data
    # Optionally you can pass :login and :password kwargs if you want to login into a real account
    @browser = Watir::Browser.new(kwargs.fetch(:browser, :chrome))
    @account_data = Accounts.new
    @transaction_data = Transactions.new
    @login = kwargs.fetch(:login, 'testaccount')
    @password = kwargs.fetch(:password, 'testpassword')
  end

  def login_demo_account
    # Login into demo account
    @browser.goto 'https://demo.bank-on-line.ru/'
    @browser.li(class: %w[enter with-hover text-center]).click
    @browser.link(id: 'btnDemoLogon').click
  end

  def login_with_credentials
    # Login using credentials
    # :login and :password need to be passed on Scraper instance or can be added later via attr_accessor
    @browser.goto 'https://demo.bank-on-line.ru/'
    @browser.li(class: %w[enter with-hover text-center]).click
    @browser.text_field(prefix: 'user').set @login
    @browser.text_field(prefix: 'pswrd').set @password
    @browser.button(id: 'btnLogon').click
  end

  def fetch_account_data
    # Open Accounts page
    # Get entire table data into 2D array
    # If table headers are present in table find the index to slice them (Supposed header rows contain only string data)
    # For each row in the new table without headers get account_data ('name', 'currency', 'balance'...)
    # and add new account_data to Accounts class instance
    @browser.goto 'https://demo.bank-on-line.ru/#Contracts'
    table_data = @browser.table(id: 'contracts-list').strings
    t_header_index = table_data.index { |n| n.join =~ /\d/ }
    cleaned_table = table_data.slice(t_header_index..-1)
    cleaned_table.each do |row|
      name = row[1]
      currency = row[2].slice(-3..-1)
      balance = row[4].delete(' ').to_i
      @account_data.add_account(name: name, currency: currency, balance: balance)
    end
  end

  def fetch_transaction_data(**kwargs)
    accounts = @account_data.get_accounts(kwargs)
    accounts.each do |account|
      account_name = account.fetch('name')
      @browser.goto "https://demo.bank-on-line.ru/#Contracts/#{account_name}/Transactions"
      date_picker(browser_instance: @browser, date: '2020-7-16')
      @browser.span(id: 'getTranz').click
      table_data = []
      @browser.table(class: 'cp-tran-with-balance').wait_until_present
      @browser.table(class: 'cp-tran-with-balance').tbody.trs.each do |tr|
        if tr.class_name.include? 'cp-item cp-transaction' and not tr.class_name.include? 'cp-income'
          transaction = ['withdraw']
          tr.each { |td| transaction.append(td.text) unless td.text.empty? }
          table_data.append(transaction)
        elsif tr.class_name.include? 'cp-income'
          transaction = ['deposit']
          tr.each { |td| transaction.append(td.text) unless td.text.empty? }
          table_data.append(transaction)
        end
      end
      table_data.each do |row|
        date = row[-3]
        description = row[3]
        amount = row[-2].delete(' ').to_i
        amount = -amount if row.first.include? 'withdraw'
        currency = symbol_to_short(row[-2][-1])
        @transaction_data.add_transaction(date: date, description: description,
                                          amount: amount, currency: currency,
                                          account_name: account_name)
      end
    end
  end
end



def main
  scraper = Scraper.new
  scraper.login_demo_account
  scraper.account_data.instance_reset
  scraper.transaction_data.instance_reset
  scraper.fetch_account_data
  scraper.account_data.print_json_account_data
  scraper.account_data.save_to_file
  scraper.fetch_transaction_data
  scraper.transaction_data.print_json_transaction_data
  scraper.transaction_data.save_to_file
  sleep(999)
end

if __FILE__ == $0
  main
end
