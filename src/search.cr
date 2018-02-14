module Illuminator
  alias Message = NamedTuple(file: String, line: Int32, time: String, nickname: String, text: String)
  alias FileResult = NamedTuple(file: String, messages: Array(Message))

  class Search
    @@PAGE_SIZE = 100

    getter results : Array(FileResult)
    getter pages_total : Int32

    # read search resuts from memory buffer
    def initialize(path : String, request : String, page : Int32)
      @results = [] of FileResult
      messages = [] of Message
      command = "grep -rn '#{path}' -e \"#{request}\" --line-buffered"
      io = IO::Memory.new
      Process.run(command, shell: true, output: io)
      iterator = io.to_s.each_line
      @pages_total = (iterator.size / @@PAGE_SIZE.to_f).ceil.to_i
      iterator.rewind
      iterator.skip(page * @@PAGE_SIZE).first(@@PAGE_SIZE).each do |line|
        messages << parse_line(line)
      end
      io.clear
      io.close
      messages.chunks { |message| message[:file] }.each { |file, messages|
        @results << {file: file, messages: messages}
      }
    end

    def parse_line(line)
      file = line[/^.*?\/([^\/]+?):/, 1]
      number = line[/:(\d+):\[/, 1].to_i - 1
      time = line[/(\[.+?\])/, 1]
      nickname = line[/^\S+\s(\S+)/, 1]
      text = line[/^\S+\s\S+\s(.*)$/, 1]
      {file: file, line: number, time: time, nickname: HTML.escape(nickname), text: HTML.escape(text)}
    end
  end
end
