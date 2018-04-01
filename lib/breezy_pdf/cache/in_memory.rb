module BreezyPDF::Cache
  class InMemory
    def initialize
      @map = {}
    end

    def set(key, value, *opts)
      @map[key] = { value: value, last_accessed: Time.now.to_f }
      remove_last_accessed!

      true
    end

    def get(key)
      @map[key][:value] if @map[key]
    end

    def fetch(key, &blk)
      return get(key) if get(key)

      value = blk.call
      set(key, value)

      value
    end

    private

    def remove_last_accessed!
      return if @map.size <= 1000

      sorted_map = @map.sort_by { |k,v| v[:last_accessed] }
      @map.delete(sorted_map.first.first)
    end
  end
end
