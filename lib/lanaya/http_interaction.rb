module Lanaya
  class HTTPInteraction < Struct.new(:request, :response, :recorded_at)
    def initialize(*args)
      super
      self.recorded_at || = Time.now
    end
  end
end
