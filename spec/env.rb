require 'rubygems'
require 'sinatra'
require 'sinatra/test/rspec'
require 'dm-sweatshop'
require 'elementor'
require 'elementor/spec'

root = File.join(File.dirname(__FILE__), '..')

require "#{root}/amnesia.rb"
require "#{root}/spec/support/helpers"
require "#{root}/spec/support/factory"

Amnesia.new(File.join(File.dirname(__FILE__), 'support', 'amnesia_config.yml'))

DataMapper.auto_migrate!

include Amnesia::Spec::Helper
include Elementor

set :public, "#{root}/public"
set :views,  "#{root}/views"
