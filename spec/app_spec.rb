require 'rack/test'
ENV['RACK_ENV'] = 'test'

RSpec.describe KumonosSds::App do
  include Rack::Test::Methods
  def app
    KumonosSds::App
  end

  let(:service_name) { 'test' }

  specify 'get, register, get, deregister' do
    get "/v1/registration/#{service_name}"
    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res).to eq('hosts' => [])

    payload = { hosts: [{ ip_address: '10.10.10.2', port: 3000 }] }
    post "/v1/registration/#{service_name}", payload.to_json
    expect(last_response.status).to eq(201)

    get "/v1/registration/#{service_name}"
    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res['hosts'].size).to eq(1)
    expect(res['hosts'][0]).to eq(
      'ip_address' => '10.10.10.2',
      'port' => 3000,
      'tags' => {}
    )

    payload = { hosts: [{ ip_address: '10.10.10.2', port: 3000 }] }
    post "/v1/deregistration/#{service_name}", payload.to_json
    expect(last_response.status).to eq(201)

    get "/v1/registration/#{service_name}"
    expect(last_response.status).to eq(200)
    res = JSON.parse(last_response.body)
    expect(res['hosts'].size).to eq(0)
  end
end
