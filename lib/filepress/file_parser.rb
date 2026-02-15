require "yaml"

module Filepress
  class FileParser
    FRONTMATTER_PATTERN = /\A---\s*\n(.*?\n?)---\s*\n?(.*)\z/m

    attr_reader :attributes, :body

    def initialize(raw_content)
      @attributes, @body = parse(raw_content)
    end

    private

    def parse(raw_content)
      if (match = raw_content.match(FRONTMATTER_PATTERN))
        attributes = YAML.safe_load(match[1], permitted_classes: [Date, Time, Symbol]) || {}
        body = match[2].strip
      else
        attributes = {}
        body = raw_content.strip
      end

      [attributes.symbolize_keys, body]
    end
  end
end
