RSpec.describe KumonosSds::Host do
  specify 'identity' do
    a = KumonosSds::Host.new('10.10.10.2', 3000)
    b = KumonosSds::Host.new('10.10.10.2', 3000)
    c = KumonosSds::Host.new('10.10.10.3', 3000)
    d = KumonosSds::Host.new('10.10.10.2', 2000)
    e = KumonosSds::Host.new('10.10.10.3', 2000)
    a2 = KumonosSds::Host.new('10.10.10.2', 3000, 'ap-northeast-1a')
    a3 = KumonosSds::Host.new('10.10.10.2', 3000, 'ap-northeast-1b')
    a4 = KumonosSds::Host.new('10.10.10.2', 3000, 'ap-northeast-1a', true)
    a5 = KumonosSds::Host.new('10.10.10.2', 3000, 'ap-northeast-1a', true, 100)

    expect(a == b).to eq(true)
    expect(a == c).to eq(false)
    expect(a == d).to eq(false)
    expect(a == e).to eq(false)

    # Ignore identify of tags
    expect(a == a2).to eq(true)
    expect(a == a3).to eq(true)
    expect(a2 == a3).to eq(true)
    expect(a == a4).to eq(true)
    expect(a == a5).to eq(true)
  end
end
