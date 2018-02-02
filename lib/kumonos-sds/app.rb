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

    def error_400(message)
      content_type :json
      status 400
      { error: message }.to_json
    end

    set :raise_errors, true
    set :show_exceptions, false

    get '/v1/registration/:service_name' do
      hosts = @storage.fetch(params[:service_name])

      content_type :json
      { hosts: hosts.map(&:to_h) }.to_json
    end

    # expect parameter: { hosts: [host] }
    #   where host like { ip_address: "", port: 1, az: '', canary: false, load_balancing_weight: 100 }
    #   where az, canary, load_balancing_weight can be null.
    post '/v1/registration/:service_name' do
      begin
        payload = JSON.parse(request.body.read)
      rescue JSON::ParserError
        return error_400('Invalid JSON given.')
      end

      hosts = payload['hosts']
      unless hosts.class == Array
        return error_400('`hosts` is missing.')
      end

      hosts.each do |host_hash|
        host_hash.keys.each do |k|
          unless %w(ip_address port az canary load_balancing_weight).include?(k)
            return error_400("Invalid key: `host.#{k}`.")
          end
        end
        unless %w(ip_address port).all? { |k| host_hash.has_key?(k) && !host_hash[k].nil? }
          return error_400('`host.ip_address` or `host.port` are missing or have a null value.')
        end
      end

      hosts.each do |h|
        host = Host.from_hash(h)
        @storage.update(params[:service_name], host)
      end

      content_type :json
      status 201
      {}.to_json
    end

    # expect parameter: { hosts: [host] }
    #   where host like { ip_address: "", port: 1 }
    post '/v1/deregistration/:service_name' do
      begin
        payload = JSON.parse(request.body.read)
      rescue JSON::ParserError
        return error_400('Invalid JSON given.')
      end

      hosts = payload['hosts']
      unless hosts.class == Array
        return error_400('`hosts` is missing.')
      end

      hosts.each do |host_hash|
        host_hash.keys.each do |k|
          unless %w(ip_address port).include?(k)
            return error_400("Invalid key: `host.#{k}`.")
          end
        end
        unless %w(ip_address port).all? { |k| host_hash.has_key?(k) && !host_hash[k].nil? }
          return error_400('`host.ip_address` or `host.port` are missing or have a null value.')
        end
      end

      hosts.each do |h|
        host = Host.from_hash(h)
        @storage.delete(params[:service_name], host)
      end

      content_type :json
      status 201
      {}.to_json
    end
  end
end
