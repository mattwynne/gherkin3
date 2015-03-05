require 'gherkin/dialect'

module Gherkin
  class TokenMatcher
    attr_reader :dialect

    def initialize(dialect_name = 'en')
      @dialect_name = dialect_name
      @dialect = Dialect.for(@dialect_name)
      @active_doc_string_separator = nil
    end

    def match_TagLine(token)
      return false unless token.line.start_with?('@')

      set_token_matched(token, 'TagLine', null, null, null, token.line.tags)
      true
    end

    def match_FeatureLine(token)
      match_title_line(token, 'FeatureLine', dialect.feature)
    end

    def match_ScenarioLine(token)
      match_title_line(token, 'ScenarioLine', dialect.scenario)
    end

    def match_ScenarioOutlineLine(token)
      match_title_line(token, 'ScenarioOutlineLine', dialect.scenario_outline)
    end

    def match_BackgroundLine(token)
      match_title_line(token, 'BackgroundLine', dialect.background)
    end

    def match_ExamplesLine(token)
      match_title_line(token, 'ExamplesLine', dialect.examples)
    end

    def match_TableRow(token)
      return false unless token.line.start_with?('|')
      # TODO: indent
      set_token_matched(token, 'TableRow', nil, nil, nil, token.line.table_cells)
      true
    end

    def match_Empty(token)
      return false unless token.line.empty?
      set_token_matched(token, 'Empty', nil, nil, 0)
      true
    end

    def match_Comment(token)
      return false unless token.line.start_with?('#')
      text = token.line.get_line_text(0) #take the entire line, including leading space
      set_token_matched(token, 'Comment', text, nil, 0)
      true
    end

    def match_Language(token)
      return false unless token.line.start_with?('#language:')

      @dialect_name = token.line.get_rest_trimmed('#language:'.length)
      @dialec = Dialect.for(@dialect_name)
      raise "Unknown dialect: #{@dialect_name}" unless dialect
      set_token_matched(token, 'Language', @dialect_name)
      true
    end

    def match_DocStringSeparator(token)
      if @active_doc_string_separator.nil?
        # open
        _match_DocStringSeparator(token, '"""', true) ||
        _match_DocStringSeparator(token, '```', true)
      else
        # close
        _match_DocStringSeparator(token, @active_doc_string_separator, false)
      end
    end

    def _match_DocStringSeparator(token, separator, is_open)
      return false unless token.line.start_with?(separator)

      content_type = nil
      if is_open
        contentType = token.line.getRestTrimmed(separator.length)
        @active_doc_string_separator = separator
        indent_to_remove = token.line.indent
      else
        @active_doc_string_separator = nil
        indent_to_remove = 0
      end

      # TODO: Use the separator as keyword. That's needed for pretty printing.
      set_token_matched(token, 'DocStringSeparator', content_type)
      true
    end

    def match_EOF(token)
      return false unless token.eof?
      set_token_matched(token, 'EOF')
      true
    end

    def match_StepLine(token)
      keywords = dialect.given +
                 dialect.when +
                 dialect.then +
                 dialect.and +
                 dialect.but

      keyword = keywords.detect { |k| token.line.start_with?(k) }

      return false unless keyword

      title = token.line.get_rest_trimmed(keyword.length)
      set_token_matched(token, 'StepLine', title, keyword)
      return true
    end

    private
    def match_title_line(token, token_type, keywords)
      keyword = keywords.detect { |k| token.line.start_with_title_keyword?(k) }

      return false unless keyword

      title = token.line.get_rest_trimmed(keyword.length + ':'.length)
      set_token_matched(token, token_type, title, keyword)
      true
    end

    def set_token_matched(token, matched_type, text=nil, keyword=nil, indent=nil, items=[])
      token.matched_type = matched_type
      token.matched_text = text
      token.matched_keyword = keyword
      token.matched_indent = indent || (token.line && token.line.indent) || 0
      token.matched_items = items
      token.location.column = token.matched_indent + 1
      token.matched_gherkin_dialect = @dialect_name
    end
  end
end
