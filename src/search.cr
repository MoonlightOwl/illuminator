module Illuminator
  alias Message = NamedTuple(file: String, line: Int32, time: String, nickname: String, text: String)
  alias FileResult = NamedTuple(file: String, messages: Array(Message))

  class Search
    @@PAGE_SIZE = 100

    getter results : Array(FileResult)
    getter pages_total : Int32

    # read search resuts from memory buffer
    def initialize(path : String, files : Array(String), request : String, page : Int32)
      @results = [] of FileResult
      @pages_total = 0
      total = 0
      offset = page * @@PAGE_SIZE
      messages = [] of Message
      files.each { |file|
        number = 0
        File.each_line(path + file) do |line|
          if line.downcase.includes? request
            if total >= offset && total < offset + @@PAGE_SIZE
              messages << parse_line file, number, line
            end
            total += 1
          end
          number += 1
        end
        if !messages.empty?
          @results << {file: file, messages: messages}
          messages = [] of Message
        end
        @pages_total = total / @@PAGE_SIZE
      }
    end

    def parse_line(file, number, line)
      time = line[/(\[.+?\])/, 1]
      nickname = line[/^\S+\s(\S+)/, 1]
      text = line[/^\S+\s\S+\s(.*)$/, 1]
      {file: file, line: number, time: time, nickname: HTML.escape(nickname), text: HTML.escape(text)}
    end
  end
end
