module Illuminator
  class Renderer
    @tag_was_opened = false
    @stack_did_change = false
    @stack = {} of String => (String | Bool)
    @stack_defaults = {
      "fore" => "99", "back" => "99",
      "bold" => false, "italic" => false, "strikethrough" => false, "underline" => false,
    }

    def set_stack_to_defaults
      @stack_defaults.each do |key, value|
        @stack[key] = value
      end
    end

    def is_stack_default?
      @stack.all? do |key, value|
        value == @stack_defaults[key]
      end
    end

    # generate HTML line with formatted text based on a line from IRC log
    def renderLine(text : String)
      set_stack_to_defaults
      @stack_did_change = false
      @tag_was_opened = false
      #
      String.build do |str|
        chars = text.each_char
        loop do
          char = chars.next
          case char
          when Iterator::Stop::INSTANCE
            break
          when '\u0002' # bold
            @stack["bold"] = true
            @stack_did_change = true
          when '\u001D' # italic
            @stack["italic"] = true
            @stack_did_change = true
          when '\u001F' # underline
            @stack["underline"] = true
            @stack_did_change = true
          when '\u001E' # strikethrough
            @stack["strikethrough"] = true
            @stack_did_change = true
          when '\u0003' # color
            fore = readCode(chars)
            break if fore.is_a? Iterator::Stop
            @stack["fore"] = fore
            @stack_did_change = true
            next_one = chars.next
            if next_one == ','
              back = readCode(chars)
              break if back.is_a? Iterator::Stop
              @stack["back"] = back
            else
              put(str, next_one)
            end
          when '\u000F' # reset
            set_stack_to_defaults
            @stack_did_change = true
          else
            put(str, char)
          end
        end
        if @tag_was_opened
          str << "</span>"
        end
      end
    end

    def readCode(chars)
      first = chars.next
      second = chars.next
      if first.is_a? Iterator::Stop || second.is_a? Iterator::Stop
        Iterator::Stop::INSTANCE
      else
        String.build do |code|
          code << first
          code << second
        end
      end
    end

    def put(str, char)
      if @stack_did_change
        if @tag_was_opened
          str << "</span>"
        end
        if is_stack_default?
          @tag_was_opened = false
        else
          @tag_was_opened = true
          str << "<span class=\""
          if @stack["fore"] != @stack_defaults["fore"]
            str << "fore#{@stack["fore"]}"
          end
          if @stack["back"] != @stack_defaults["back"]
            str << " back#{@stack["back"]}"
          end
          if @stack["bold"]
            str << " bold"
          end
          if @stack["italic"]
            str << " italic"
          end
          if @stack["strikethrough"]
            str << " strikethrough"
          end
          if @stack["underline"]
            str << " underline"
          end
          str << "\">"
        end
        @stack_did_change = false
      end
      str << char
    end
  end
end
