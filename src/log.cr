module Illuminator
  class Log
    getter messages

    # read log from file
    def initialize(filename : String)
      @messages = [] of NamedTuple(time: String, nickname: String, text: String)
      File.each_line(filename) do |line|
        @messages << parse_line(line)
      end
    end

    # split one log line to the significant parts
    def parse_line(line)
      time = line[/^(\S+)/]?
      nickname = line[/^\S+\s(\S+)/, 1]?
      text = line[/^\S+\s\S+\s(.*)$/, 1]?
      if !time.is_a?(Nil) && !nickname.is_a?(Nil) && !text.is_a?(Nil)
        {time: time, nickname: HTML.escape(nickname), text: HTML.escape(text)}
      else
        {time: "", nickname: "", text: "* * *"}
      end
    end
  end
end
