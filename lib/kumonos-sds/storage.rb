module KumonosSds
  # Storage class
  class Storage
    def initialize
      @mem = {}
    end

    # @param [String] service_name
    # @param [Host] host
    def create(service_name, host)
      if @mem.has_key?(service_name)
        @mem[service_name] = [host]
      else
        if @mem[service_name].include?(host)
          @mem[service_name].delete(host)
        end
        @mem[service_name] << host
      end
    end

    # @param [String] service_name
    # @return [Host]
    def fetch(service_name)
      @mem[service_name] || []
    end

    # @param [String] service_name
    # @param [Array<Host>] hosts
    def delete(service_name, hosts)
    end
  end
end
