require 'watir'

def init_browser
  # Init new browser with chromedriver
  Watir::Browser.new(:chrome)
end

def login_demo_account
  browser = init_browser
  # Login into demo account
  browser.goto 'https://demo.bank-on-line.ru/'
  browser.li(class: %w[enter with-hover text-center]).click
  browser.link(id: 'btnDemoLogon').click
  sleep(30)
end

def login_with_credentials
  login = 'testaccount'
  password = 'testpassword'
  browser = init_browser
  # Login using credentials
  browser.goto 'https://demo.bank-on-line.ru/'
  browser.li(class: %w[enter with-hover text-center]).click
  browser.text_field(prefix: 'user').set login
  browser.text_field(prefix: 'pswrd').set password
  browser.button(id: 'btnLogon').click
  sleep(30)
end

login_demo_account
# login_with_credentials
