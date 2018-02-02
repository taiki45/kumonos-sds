require 'rack/test'
ENV['RACK_ENV'] = 'test'

RSpec.describe KumonosSds::App do
  include Rack::Test::Methods
  def app
    KumonosSds::App
  end

  def req_register(body)
    post '/v1/registration/test', body
    JSON.parse(last_response.body)
  end

  def req_deregister(body)
    post '/v1/deregistration/test', body
    JSON.parse(last_response.body)
  end

  def req_fetch
    get '/v1/registration/test'
    JSON.parse(last_response.body)
  end

  def create_payload(ip_address: nil, port: nil)
    {
      hosts: [
        {
          ip_address: ip_address || '10.10.10.2',
          port: port || 3000
        }
      ]
    }
  end

  specify 'get, register, get, deregister' do
    res = req_fetch
    expect(last_response.status).to eq(200)
    expect(res).to eq('hosts' => [])

    req_register(create_payload.to_json)
    expect(last_response.status).to eq(201)

    res = req_fetch
    expect(last_response.status).to eq(200)
    expect(res['hosts'].size).to eq(1)
    expect(res['hosts'][0]).to eq(
      'ip_address' => '10.10.10.2',
      'port' => 3000,
      'tags' => {}
    )

    # Register same host
    req_register(create_payload.to_json)
    expect(last_response.status).to eq(201)
    res = req_fetch
    expect(last_response.status).to eq(200)
    expect(res['hosts'].size).to eq(1)

    # Register another host
    req_register(create_payload(port: 4000).to_json)
    expect(last_response.status).to eq(201)
    res = req_fetch
    expect(last_response.status).to eq(200)
    expect(res['hosts'].size).to eq(2)

    # Deregister
    payload = create_payload
    req_deregister(payload.to_json)
    expect(last_response.status).to eq(201)
    res = req_fetch
    expect(last_response.status).to eq(200)
    expect(res['hosts'].size).to eq(1)

    # Deregister same host
    payload = create_payload
    req_deregister(payload.to_json)
    expect(last_response.status).to eq(201)
    res = req_fetch
    expect(last_response.status).to eq(200)
    expect(res['hosts'].size).to eq(1)
  end

  specify 'deregister non-existing host' do
    req_deregister(create_payload.to_json)
    expect(last_response.status).to eq(201)
  end

  describe 'registration' do
    specify 'invalid json' do
      req_register('')
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/Invalid JSON/)
    end

    specify 'missing hosts' do
      req_register({ho: []}.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/hosts.+is.+missing/)
    end

    specify 'invalid hosts' do
      req_register({hosts: {}}.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/hosts.+is.+missing/)
    end

    specify 'host is missing keys' do
      payload = {hosts: [{ ip_address: '10.10.10.2' }] }
      req_register(payload.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/port.+missing/)
    end

    specify 'host has null values' do
      payload = {hosts: [{ ip_address: nil, port: 3000 }] }
      req_register(payload.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/null value/)
    end

    specify 'host has invalid keys' do
      payload = {hosts: [{ ip_address: '10.10.10.2', port: 3000, extra: 'a' }] }
      req_register(payload.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/Invalid key/)
    end
  end

  describe 'deregistration' do
    specify 'invalid json' do
      req_deregister('')
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/Invalid JSON/)
    end

    specify 'missing hosts' do
      req_deregister({ho: []}.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/hosts.+is.+missing/)
    end

    specify 'invalid hosts' do
      req_deregister({hosts: {}}.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/hosts.+is.+missing/)
    end

    specify 'host is missing keys' do
      payload = {hosts: [{ ip_address: '10.10.10.2' }] }
      req_deregister(payload.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/port.+missing/)
    end

    specify 'host has null values' do
      payload = {hosts: [{ ip_address: nil, port: 3000 }] }
      req_deregister(payload.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/null value/)
    end

    specify 'host has invalid keys' do
      payload = {hosts: [{ ip_address: '10.10.10.2', port: 3000, extra: 'a' }] }
      req_deregister(payload.to_json)
      expect(last_response.status).to eq(400)
      expect(last_response.body).to match(/Invalid key/)
    end
  end
end
