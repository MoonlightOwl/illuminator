module Illuminator
  class Config
    property path : String
    @hash : Hash(String, String)

    def initialize(@path)
      lines = File.read_lines(path)
      @hash = lines.map { |line| line.split(':') }.to_h
    end

    def get(key)
      @hash[key]
    end
  end
end
