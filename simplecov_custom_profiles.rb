require 'simplecov'
SimpleCov.profiles.define 'msfl' do
  add_filter '/spec'
  add_filter '/test'
end