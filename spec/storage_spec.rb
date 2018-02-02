RSpec.describe KumonosSds::Storage do
  let(:storage) { KumonosSds::Storage.new }

  specify 'create, fetch, update and delete' do
    service_name = 'test'
    a = KumonosSds::Host.new('10.10.10.2', 3000)
    b = KumonosSds::Host.new('10.10.10.3', 3000)
    a2 = KumonosSds::Host.new('10.10.10.2', 3000, 'ap-northeast-1a')

    storage.update(service_name, a)
    expect(storage.fetch(service_name)).to eq([a])

    storage.update(service_name, b)
    expect(storage.fetch(service_name).size).to eq(2)
    expect(storage.fetch(service_name).include?(a)).to eq(true)
    expect(storage.fetch(service_name).include?(b)).to eq(true)

    # Update with same host but different host
    storage.update(service_name, a2)
    expect(storage.fetch(service_name).size).to eq(2)
    expect(storage.fetch(service_name).find { |e| e == a2 }.tags[:az]).to eq('ap-northeast-1a')

    storage.delete(service_name, a2)
    expect(storage.fetch(service_name).size).to eq(1)
    expect(storage.fetch(service_name).include?(a2)).to eq(false)
    expect(storage.fetch(service_name).include?(b)).to eq(true)
  end
end
