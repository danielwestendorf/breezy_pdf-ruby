module BreezyPDF::Cache
  class InMemory
    def initialize
      @map = {}
      @monitor = Monitor.new
    end

    def write(key, value, opts = {})
      synchronize do
        write_value(key, value, opts)
      end
    end

    def read(key)
      synchronize do
        get_value(key)
      end
    end

    def fetch(key, &blk)
      synchronize do
        fetch_value(key, blk)
      end
    end

    private

    def synchronize(&block) # :nodoc:
      @monitor.synchronize(&block)
    end

    def write_value(key, value, opts)
      hash = { value: value, last_accessed: Time.now }
      hash[:expires_at] = (Time.now + opts[:expires_in].to_f) if opts[:expires_in]

      @map[key] = hash
      remove_last_accessed!

      true
    end

    def get_value(key)
      key_value = read_key(key)

      if key_value && key_value[:expires_at]
        if key_value[:expires_at] <= Time.now
          @map.delete(key) # The key has expired
          nil
        else
          key_value[:value]
        end
      elsif key_value
        key_value[:value]
      end
    end

    def read_key(key)
      if @map[key]
        @map[key][:last_accessed] = Time.now
        @map[key]
      end
    end

    def fetch_value(key, blk)
      stored_value = read(key)
      return stored_value if stored_value

      value = blk.call
      write(key, value)

      value
    end

    def remove_last_accessed!
      return if @map.size <= 1000

      sorted_map = @map.sort_by { |k,v| v[:last_accessed] }
      @map.delete(sorted_map.first.first)
    end
  end
end
