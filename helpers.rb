require 'json'

# Class accounts, for managing account_data object with load/save to file and update methods
class Accounts
  def initialize
    @file_path = './account_data.json'
    @account_data = {}
    load_from_file
  end

  def get_accounts(**kwargs)
    # Return one account by name or return all, (i.e. get_account(account_name: "40817810200000055320"))
    account_name = kwargs.fetch(:account_name, nil)
    accounts = @account_data.fetch('accounts')
    if account_name
      accounts.select { |account| account['name'] == account_name }
    else
      accounts
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

    @account_data['accounts'].append(new_account)
  end

  def print_json_account_data
    # Printout of the stored data in JSON format
    puts JSON.pretty_generate(@account_data)
  end

  def update_account_val(**kwargs)
    # Update or modify a key/value pair for a given account based on parameter 'add' or 'update'
    # 'add' will add up the existing value with the new value
    # 'update' will replace existing value with a new one
    account_name = kwargs.fetch(:name)
    account_key = kwargs.fetch(:key)
    key_value = kwargs.fetch(:value)
    update_method = kwargs.fetch(:method)

    accounts = @account_data['accounts']

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
    @account_data = { 'accounts' => accounts }
  end

  def save_to_file
    # Save to file method, will store account_data of the current instance on disk
    File.write(@file_path, JSON.pretty_generate(@account_data))
  end

  def load_from_file
    # Load from file method, if any account_data was previously stored
    # this method will be called when instance is initialized
    begin
      account_data = JSON.parse(File.open(@file_path).read)
    rescue StandardError
      account_data = { 'accounts' => [] }
    end
    @account_data = account_data
  end

  def instance_reset
    # Clean instance of any data if needed
    @account_data = { 'accounts' => [] }
  end
end


# Class Transactions, for managing transaction_data object with load/save to file and printout method
class Transactions
  def initialize
    @file_path = './transaction_data.json'
    @transaction_data = {}
    load_from_file
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

    @transaction_data['transactions'].append(new_transaction)
  end

  def print_json_transaction_data
    # Printout of the stored data in JSON format
    puts JSON.pretty_generate(@transaction_data)
  end

  def save_to_file
    # Save to file method, will store transactions_data of the current instance on disk
    File.write(@file_path, JSON.pretty_generate(@transaction_data))
  end

  def load_from_file
    # Load from file method, if any transaction_data was previously stored
    # this method will be called when instance is initialized
    begin
      transaction_data = JSON.parse(File.open(@file_path).read)
    rescue StandardError
      transaction_data = { 'transactions' => [] }
    end
    @transaction_data = transaction_data
  end

  def instance_reset
    # Clean instance of any data if needed
    @transaction_data = { 'transactions' => [] }
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
