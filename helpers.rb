# frozen_string_literal: true

require 'json'

# Base Class for Accounts and Transactions classes with print to json and simple load/save to file features
class BaseClass
  def initialize(file_path)
    @file_path = file_path
    @data = {}
    load_from_file
  end

  def print_json_data
    # Printout of the stored data in JSON format
    puts JSON.pretty_generate(@data)
  end

  def save_to_file
    # Save to file method, will store data of the current instance on disk
    File.write(@file_path, JSON.pretty_generate(@data))
  end

  def load_from_file
    # Load from file method, if any data was previously stored
    # this method will be called when instance is initialized
    begin
      data = JSON.parse(File.open(@file_path).read)
    rescue StandardError
      data = {}
    end
    @data = data
  end
end

# Class accounts, for managing account_data object and update methods
class Accounts < BaseClass
  def initialize(file_path = './account_data.json')
    super(file_path)
    instance_reset if @data.empty?
  end

  def get_accounts(**kwargs)
    # Return one account by name or return all, (i.e. get_account(account_name: "40817810200000055320"))
    account_name = kwargs.fetch(:account_name, nil)
    accounts = @data.fetch('accounts')
    if account_name
      accounts.select { |account| account['name'] == account_name }
    else
      accounts
    end
  end

  def add_accounts_from_table(table)
    table.each do |row|
      name = row[1]
      currency = row[2].slice(-3..-1)
      balance = row[4].delete(' ').to_i
      add_account(name: name, currency: currency, balance: balance)
    end
  end

  def add_account(**kwargs)
    # Add new account object to the class instance
    new_account = {
      'name' => kwargs.fetch(:name),
      'currency' => kwargs.fetch(:currency),
      'balance' => kwargs.fetch(:balance, 0),
      'nature' => kwargs.fetch(:nature, 'bank_account'),
      'transactions' => kwargs.fetch(:transactions, [])
    }

    @data['accounts'].append(new_account)
  end

  def update_account_val(**kwargs)
    # Update or modify a key/value pair for a given account based on parameter 'add' or 'update'
    # 'add' will add up the existing value with the new value
    # 'update' will replace existing value with a new one
    account_name = kwargs.fetch(:name)
    account_key = kwargs.fetch(:key)
    key_value = kwargs.fetch(:value)
    update_method = kwargs.fetch(:method)

    accounts = @data['accounts']

    current_acc = accounts.select { |account| account['name'] == account_name }.tap { |account| accounts -= account }

    case update_method
    when 'update'
      current_acc.first[account_key] = key_value
    when 'add'
      current_acc.first[account_key] += key_value
    else
      return 'Method update or add is required'
    end

    accounts.append(current_acc.first)
    @data = { 'accounts' => accounts }
  end

  def instance_reset
    # Clean instance of any data if needed
    @data = { 'accounts' => [] }
  end
end

# Class Transactions, for managing transaction_data object with load/save to file and printout method
class Transactions < BaseClass
  def initialize(file_path = './transaction_data.json')
    super(file_path)
    instance_reset if @data.empty?
  end

  def get_account_transactions(account_name)
    transactions = @data['transactions']
    transactions.select { |transaction| transaction['account_name'] == account_name }
  end

  def add_transactions_from_table(account_name, table_data)
    table_data.each do |row|
      date = row[9]
      description = row[7]
      amount = row[6].delete(' ').to_i
      amount = -amount if row.first.include? 'withdraw'
      currency = row[4]
      add_transaction(date: date, description: description,
                                        amount: amount, currency: currency,
                                        account_name: account_name)
    end
  end

  def add_transaction(**kwargs)
    # Add new transaction object to the class instance
    new_transaction = {
      'date' => kwargs.fetch(:date),
      'description' => kwargs.fetch(:description, ''),
      'amount' => kwargs.fetch(:amount),
      'currency' => kwargs.fetch(:currency),
      'account_name' => kwargs.fetch(:account_name)
    }

    @data['transactions'].append(new_transaction)
  end

  def instance_reset
    # Clean instance of any data if needed
    @data = { 'transactions' => [] }
  end
end

def date_picker(**kwargs)
  # DateField read-only field date picker (i.e date_picker(browser_instance: browser, date: "2020-7-16"))
  browser = kwargs.fetch(:browser_instance)
  date = kwargs.fetch(:date)
  year, month, date = date.split('-')
  month = (month.to_i - 1).to_s
  browser.input(id: 'DateFrom').click
  browser.select(class: 'ui-datepicker-year').click
  browser.select_list(class: 'ui-datepicker-year').select year
  browser.select(class: 'ui-datepicker-month').click
  browser.select_list(class: 'ui-datepicker-month').select month
  browser.link(text: date).click
end

def symbol_to_short(sym)
  # Return currency short name based on currency symbol
  hash = {
    '₽' => 'RUB',
    '$' => 'USD',
    '€' => 'EUR'
  }
  hash[sym]
end

def print_json_all_data(**kwargs)
  # Print all stored data to the terminal
  account_data = kwargs.fetch(:account_data, Accounts.new)
  transaction_data = kwargs.fetch(:transaction_data, Transactions.new)
  all_accounts = account_data.get_accounts
  all_accounts.each do |account|
    account_name = account.fetch('name')
    account_transactions = transaction_data.get_account_transactions(account_name)
    account_data.update_account_val(name: account_name,
                                    key: 'transactions',
                                    value: account_transactions,
                                    method: 'update')
  end
  account_data.print_json_data
end

def html_table_data(**kwargs)
  # Receive html data for a table and return an array based on parameters 'row_css' and 'row_css_exclude'
  # and at the end remove empty [] arrays
  html = kwargs.fetch(:html)
  row_css = kwargs.fetch(:row_css)
  row_css_exclude = kwargs.fetch(:row_css_exclude, nil)
  rows = html.css("tr.#{row_css}")
  rows = rows.map do |row|
    row.css('td').map do |td|
      if row_css_exclude
        td.text if td.parent['class'].to_s.include?(row_css) && !td.parent['class'].to_s.include?(row_css_exclude)
      elsif td.parent['class'].to_s.include? row_css
        td.text
      end
    end.compact
  end
  rows.delete_if { |elem| elem.flatten.empty? }
end
