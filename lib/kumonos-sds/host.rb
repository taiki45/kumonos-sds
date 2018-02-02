module KumonosSds
  # Host
  Host = Struct.new(:ip_address, :port, :az, :canary, :load_balancing_weight) do
    def self.from_hash(h)
      new(*h.slice(*members).values)
    end

    def to_h
      h = super
      h.delete(:az)
      h.delete(:canary)
      h.delete(:load_balancing_weight)
      h[:tags] = {}
      h[:tags][:az] = az if az
      h[:tags][:canary] = canary if canary
      h[:tags][:load_balancing_weight] = load_balancing_weight if load_balancing_weight
      h
    end

    def ==(other)
      return false unless self.class == other.class

      ip_address == other.ip_address && port == other.port
    end
  end
end
