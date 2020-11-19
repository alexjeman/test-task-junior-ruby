# frozen_string_literal: true

require 'watir'
require 'nokogiri'
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

  def nokogiri_at_css(html, at_css)
    Nokogiri::HTML(html).at_css(at_css)
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
    # Get table data into 2D array
    # For each row in the table get account_data ('name', 'currency', 'balance'...)
    # and add new account_data to Accounts class instance
    @browser.goto 'https://demo.bank-on-line.ru/#Contracts'
    @browser.table(id: 'contracts-list').wait_until(&:present?)

    html = nokogiri_at_css(@browser.html, 'table#contracts-list')
    table_data = html_table_data(html: html, row_css: 'cp-item')

    @account_data.add_accounts_from_table(table_data)
  end

  def fetch_transaction_data(**kwargs)
    accounts = @account_data.get_accounts(kwargs)
    accounts.each do |account|
      account_name = account.fetch('name')
      @browser.goto "https://demo.bank-on-line.ru/#Contracts/#{account_name}/Transactions"
      date_picker(browser_instance: @browser, date: '2020-7-16')
      @browser.span(id: 'getTranz').click
      @browser.table(class: 'cp-tran-with-balance').wait_until(&:present?)

      html = nokogiri_at_css(@browser.html, 'table.cp-tran-with-balance')
      table_data_deposit = html_table_data(html: html, row_css: 'cp-income')
      table_data_withdraw = html_table_data(html: html, row_css: 'cp-transaction', row_css_exclude: 'cp-income')
      table_data = table_data_deposit.map { |item| ['deposit'].append(*item) } +
                   table_data_withdraw.map { |item| ['withdraw'].append(*item) }

      @transaction_data.add_transactions_from_table(account_name, table_data)
    end
  end
end

def main
  puts "\n### Using Watir gem, write a script that starts a browser instance and signs"
  puts '### into the bank interface'
  puts "###########\n"

  scraper = Scraper.new
  scraper.login_demo_account

  puts "\n### Extend your script in the way it should navigate through the bank's page,"
  puts '### and collect accounts information'
  puts "###########\n"

  scraper.account_data.instance_reset
  scraper.transaction_data.instance_reset
  scraper.fetch_account_data

  puts "\n### Accounts data should be stored in an instance of Accounts class and provide"
  puts '### a printout of the stored data in JSON format'
  puts "###########\n"

  scraper.account_data.print_json_data

  puts "\n### Extend your script in the way it should iterate over previously stored accounts"
  puts '### and navigate to the page with their transactions and save those transactions'
  puts "###########\n"

  scraper.fetch_transaction_data

  puts "\n### Transactions data should be stored in an instance of Transactions class and provide"
  puts '### a printout of the stored data in JSON format'
  puts "###########\n"

  scraper.transaction_data.print_json_data

  scraper.transaction_data.save_to_file
  scraper.account_data.save_to_file

  puts "\n### Add to your script the possibility to printout stored data in JSON format"
  puts "###########\n"

  print_json_all_data

  seconds_close = 5
  puts "\n### Script completed, browser instance will be closed in #{seconds_close} seconds"
  puts "###########\n"
  sleep(seconds_close)
  scraper.browser.close
end

main if __FILE__ == $PROGRAM_NAME
