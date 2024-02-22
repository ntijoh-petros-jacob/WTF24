require 'bundler'
Bundler.require
require_relative 'app'
ENV['BROWSER'] = 'google-chrome'
run App 