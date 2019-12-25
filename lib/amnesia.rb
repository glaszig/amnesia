require 'sinatra/base'
require 'googlecharts'
require 'haml'

$:<< File.dirname(__FILE__)

require 'amnesia/host'

module Amnesia
  class Application < Sinatra::Base
    SIZE_UNITS = %w[ Bytes KB MB GB TB PB EB ]

    set :public_folder, File.join(File.dirname(__FILE__), 'amnesia', 'public')
    set :views, File.join(File.dirname(__FILE__), 'amnesia', 'views')

    def initialize(app = nil, options = {})
      @hosts = build_hosts options[:hosts] || ENV['MEMCACHE_SERVERS'] || '127.0.0.1:11211'
      super app
    end

    def build_hosts addresses
      Array(addresses).flatten.map { |address| Amnesia::Host.new address }
    end

    use Rack::Auth::Basic, "Amnesia" do |username, password|
      user, pass = ENV['AMNESIA_CREDS'].split(':')
      username == user and password == pass
    end if ENV['AMNESIA_CREDS']

    helpers do
      def graph_url(data = [])
        Gchart.pie(data: data, size: '115x115', bg: 'ffffff00')
      end

      # https://github.com/rails/rails/blob/fbe335cfe09bf0949edfdf0c4b251f4d081bd5d7/activesupport/lib/active_support/number_helper/number_to_human_size_converter.rb
      def number_to_human_size(number, precision=1)
        number, base = Float(number), 1024

        if number.to_i < 1024
          "%d %s" % [ number.to_i, SIZE_UNITS.first ]
        else
          max = SIZE_UNITS.size - 1
          exp = (Math.log(number) / Math.log(base)).to_i
          exp = max if exp > max # avoid overflow for the highest unit
          result = number / (1024**exp)
          "%.#{precision}f %s" % [ result, SIZE_UNITS[exp] ]
        end
      end
    end

    get '/' do
      haml :index
    end

    get '/:address' do
      @host = find_host params[:address]
      @host ? haml(:host) : halt(404)
    end

    def find_host address
      @hosts.find { |h| h.address == address }
    end
  end
end
