# frozen_string_literal: true

module BreezyPDF::Cache
  # In Memory cache store for assets
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

    def fetch(key, opts = {}, &blk)
      synchronize do
        fetch_value(key, opts, blk)
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
          BreezyPDF.logger.info("[BreezyPDF] Cache miss for #{key}")
          nil
        else
          BreezyPDF.logger.info("[BreezyPDF] Cache hit for #{key}")
          key_value[:value]
        end
      elsif key_value
        BreezyPDF.logger.info("[BreezyPDF] Cache hit for #{key}")
        key_value[:value]
      else
        BreezyPDF.logger.info("[BreezyPDF] Cache miss for #{key}")
        nil
      end
    end

    def read_key(key)
      return unless @map[key]

      @map[key][:last_accessed] = Time.now
      @map[key]
    end

    def fetch_value(key, opts, blk)
      stored_value = read(key)
      return stored_value if stored_value

      value = blk.call if blk
      write(key, value, opts)

      value
    end

    def remove_last_accessed!
      return if @map.size <= 1000

      sorted_map = @map.sort_by { |_k, v| v[:last_accessed] }
      @map.delete(sorted_map.first.first)
    end
  end
end
