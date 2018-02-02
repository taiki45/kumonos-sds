require 'net/http'
require 'uri'
require 'json'

def raise_error(response = nil)
  p response if response
  p response.body if response
  raise('invalid response')
end

envoy_url = URI('http://localhost:9211')
app_url = URI('http://localhost:3081')
sds_url = URI('http://localhost:4000')
user_app_ip = nil
ab_testing_app_ip = nil

catch(:break) do
  i = 0
  loop do
    begin
      Net::HTTP.start(app_url.host, app_url.port) do |http|
        response = http.get('/ip/user-app')
        user_app_ip = response.body
        response = http.get('/ip/ab-testing-app')
        ab_testing_app_ip = response.body
        throw(:break)
      end
    rescue EOFError, SystemCallError
      raise('Can not run the app container') if i == 19 # Overall retries end within 3.8s.
      puts 'waiting the app container to run...'
      sleep((2 * i) / 100.0)
      i += 1
    end
  end
end

catch(:break) do
  i = 0
  loop do
    begin
      Net::HTTP.start(envoy_url.host, envoy_url.port) do |http|
        response = http.get('/')
        throw(:break) if response.code == '404'
      end
    rescue EOFError, SystemCallError
      raise('Can not run the envoy container') if i == 19 # Overall retries end within 3.8s.
      puts 'waiting the envoy container to run...'
      sleep((2 * i) / 100.0)
      i += 1
    end
  end
end

puts 'ensure Envoy has no healty hosts'
Net::HTTP.start(envoy_url.host, envoy_url.port) do |http|
  response = http.get('/', Host: 'user')
  p response, response.body
  raise_error if response.code != '503'

  response = http.get('/', Host: 'ab-testing')
  p response, response.body
  raise_error if response.code != '503'

  puts 'pass'
end

puts 'register hosts'
Net::HTTP.start(sds_url.host, sds_url.port) do |http|
  payload = { hosts: [{ ip_address: user_app_ip, port: 8080 }] }
  response = http.post('/v1/registration/user', payload.to_json)
  puts response.code, response.body
  raise_error if response.code != '201'

  payload = { hosts: [{ ip_address: ab_testing_app_ip, port: 8080 }] }
  response = http.post('/v1/registration/ab-testing', payload.to_json)
  puts response.code, response.body
  raise_error if response.code != '201'

  response = http.get('/v1/registration/user')
  puts response.code, response.body
  raise_error if response.code != '200'
  raise_error if JSON.parse(response.body)['hosts'].size != 1

  response = http.get('/v1/registration/ab-testing')
  puts response.code, response.body
  raise_error if response.code != '200'
  raise_error if JSON.parse(response.body)['hosts'].size != 1

  puts 'pass'
end

puts 'ensure Envoy has healty hosts'
Net::HTTP.start(envoy_url.host, envoy_url.port) do |http|
  catch(:break) do
    i = 0
    loop do
      response = http.get('/', Host: 'user')
      throw(:break) if response.code == '200'

      raise('Can not fetch healty upstreams') if i == 30
      puts 'waiting the envoy to fetch from SDS...'
      sleep((2 * i) / 100.0)
      i += 1
    end
  end

  response = http.get('/', Host: 'user')
  raise_error if response.code != '200'
  raise_error if response.body != 'GET,user,user'

  response = http.get('/', Host: 'ab-testing')
  p response, response.body
  raise_error if response.code != '200'
  raise_error if response.body != 'GET,ab-testing,ab-testing'

  puts 'pass'
end

puts 'OK'
