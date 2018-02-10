module Illuminator
  class LineIterator
    @line : String
    @index : Int32

    def initialize(@line)
      @index = 0
    end

    # get one letter and move index 1 codechar forward
    def next
      @index += 1
      if @index < @line.size + 1
        @line[@index - 1]
      else
        Iterator::Stop::INSTANCE
      end
    end

    # move iterator index to n codepoints back
    def back(n)
      @index = Math.max(@index - n, 0)
    end

    def back
      back(1)
    end
  end
end
