module KumonosSds
  # Host
  Host = Struct.new(:ip_address, :port, :az, :canary, :load_balancing_weight) do
    def self.from_hash(h)
      new(*h.slice(*members).values)
    end

    def tags
      h = {}
      h[:az] = az if az
      h[:canary] = canary if canary
      h[:load_balancing_weight] = load_balancing_weight if load_balancing_weight
      h
    end

    def to_h
      h = super
      h.delete(:az)
      h.delete(:canary)
      h.delete(:load_balancing_weight)
      h[:tags] = tags
      h
    end

    def ==(other)
      return false unless self.class == other.class

      ip_address == other.ip_address && port == other.port
    end
  end
end
