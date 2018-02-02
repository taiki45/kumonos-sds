module KumonosSds
  # Storage class
  class Storage
    def initialize
      @mem = {}
    end

    # @param [String] service_name
    # @param [Host] host
    def update(service_name, host)
      if !@mem.has_key?(service_name)
        @mem[service_name] = [host]
      else
        if (i = @mem[service_name].find_index(host))
          @mem[service_name][i] = host # update
        else
          @mem[service_name] << host # insert
        end
      end
    end

    # @param [String] service_name
    # @return [Host]
    def fetch(service_name)
      @mem[service_name] || []
    end

    # @param [String] service_name
    # @param [Array] host
    def delete(service_name, host)
      @mem[service_name].delete(host)
    end
  end
end
