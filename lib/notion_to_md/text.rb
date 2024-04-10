class NotionToMd
  class Text
    class << self
      def text(text)
        text[:plain_text]
      end

      def equation(text)
        "$$ #{text[:plain_text]} $$"
      end
    end
  end
end
