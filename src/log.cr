module Illuminator
  class Log
    getter messages

    def initialize(filename)
      @messages = [] of NamedTuple(time: String, nickname: String, text: String)
      File.each_line(filename) do |line|
        time = line[/^(\S+)/]
        nickname = line[/^\S+\s(\S+)/, 1]
        text = line[/^\S+\s\S+\s(.*)$/, 1]
        @messages << {time: time, nickname: HTML.escape(nickname), text: HTML.escape(text)}
      end
    end
  end
end
