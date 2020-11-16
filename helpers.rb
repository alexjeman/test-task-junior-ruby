require 'json'

# Class accounts, for managing account_data object with load/save to file and update methods
class Accounts
  def initialize
    @file_path = './account_data.json'
    @account_data = {}
    load_from_file
  end

  def add_account(**kwargs)
    # Add new account object to the class instance
    new_account = {
      'name' => kwargs.fetch(:name),
      'currency' => kwargs.fetch(:currency),
      'balance' => kwargs.fetch(:balance, 0),
      'nature' => kwargs.fetch(:nature, 'credit_card'),
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
end
