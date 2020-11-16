### Guideline
#### 1. (Connect) Using Watir gem, write a script that starts a browser instance and signs into the bank interface. You can use any of your web banking accounts or use the following (demo mode):

- https://demo.bank-on-line.ru
- https://my.fibank.bg/oauth2-server/login?client_id=E_BANK
- https://demo.bendigobank.com.au

#### 2. (Fetch accounts) Extend your script in the way it should navigate through the bank's page, collect accounts information with the following main parameters for each account:

- name
- currency
- balance
- nature
- transactions

#### Accounts data should be stored in an instance of Accounts class and provide a printout of the stored data in JSON format.

Example output:
```
{
  "accounts": [
    {
      "name": "account1",
      "currency": "MDL",
      "balance": 300.22,
      "nature": "credit_card",
      "transactions": []
    }
  ]
}
```
#### 3. (Fetch transactions) Extend your script in the way it should iterate over previously stored accounts and navigate to the page with their transactions and save those transactions data with the following main parameters:

- date
- description
- amount
- currency
- account_name

#### Transactions data should be stored in an instance of Transactions class and provide a printout of the stored data in JSON format.

Example output:
```
{
  "transactions": [
    {
      "date": "2015-01-15",
      "description": "bought food",
      "amount": -20.31,
      "currency": "MDL",
      "account_name": "account1"
    }
  ]
}
```
#### Your script should be able to store last 2 months history of transactions for each account (if possible).

#### 4. Add to your script the possibility to printout stored data in JSON format.

Example of output:
```
{
  "accounts": [
    {
      "name": "account1",
      "currency": "MDL",
      "balance": 300.22,
      "nature": "credit_card",
      "transactions": [
        {
          "date": "2015-01-15",
          "description": "bought food",
          "amount": -20.31,
          "currency": "MDL",
          "account_name": "account1"
        }
      ]
    }
  ]
}
```
#### 5. Install the Nokogiri gem. Use it to minimize the number of actions in Watir. Rewrite the code responsible for data parsing from Watir objects to Nokogiri. ⚠ Use CSS selectors with Nokogiri. Do not use Xpath.

Example:
```
browser.table(id: "table_id").text
Should look like:
html.at_css("table#table_id").text
```

#### 6. Use Ruby style guide (https://github.com/rubocop-hq/ruby-style-guide#source-code-layout) to clean up and refactor your code.

#### 7. (Optional) Cover your code with RSpec tests using HTML fixtures.
