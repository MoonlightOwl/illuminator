module Illuminator
  class Config
    property path : String
    @hash : Hash(String, String)

    def initialize(@path)
      lines = File.read_lines(path)
      fields = lines.map { |line| line.split(':') }.transpose
      @hash = Hash.zip(fields[0], fields[1])
      puts @hash
    end

    def get(key)
      @hash[key]
    end
  end
end
