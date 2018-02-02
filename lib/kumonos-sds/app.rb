require 'json'
require 'resolv'

require 'sinatra/base'

require 'kumonos-sds/host'
require 'kumonos-sds/storage'

module KumonosSds
  class App < Sinatra::Application
    def initialize(*args)
      super

      @storage = Storage.new
    end

    get '/v1/registration/:service_name' do
      if params[:service_name] == 'user'
        ip = Resolv.getaddress('user-app')
      elsif params[:service_name] == 'ab-testing'
        ip = Resolv.getaddress('ab-testing-app')
      else
        return [404, {}, ["unkown service_name: #{params[:service_name]}"]]
      end
      host = Host.new(ip, 8080)

      content_type :json
      { hosts: [host.to_h] }.to_json
    end

    post '/v1/registration/:service_name' do
      params[:service_name]
    end

    post '/v1/deregister' do
      params[:service_name]
      params[:hosts]
    end
  end
end
