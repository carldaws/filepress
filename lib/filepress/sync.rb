module Filepress
  class Sync
    def initialize(config)
      @model_class = config[:model_class]
      @from = config[:from]
      @extensions = config[:extensions]
      @key = config[:key]
      @body = config[:body]
      @destroy_stale = config[:destroy_stale]
    end

    def perform
      return unless table_exists?
      return unless File.directory?(@from)

      synced_identifiers = []

      @model_class.transaction do
        content_files.each do |file_path|
          identifier_value = File.basename(file_path, ".*")
          parsed = FileParser.new(File.read(file_path))

          record = @model_class.find_or_initialize_by(@key => identifier_value)
          record.assign_attributes(permitted_attributes(record, parsed.attributes))
          record.public_send(:"#{@body}=", parsed.body)
          record.save!

          synced_identifiers << identifier_value
        end

        if @destroy_stale
          @model_class.where.not(@key => synced_identifiers).destroy_all
        end
      end
    end

    private

    def table_exists?
      @model_class.connection_pool.with_connection do
        @model_class.table_exists?
      end
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      false
    end

    def permitted_attributes(record, attributes)
      known_columns = record.class.column_names.map(&:to_sym)
      attributes.select { |key, _| known_columns.include?(key) }
    end

    def content_files
      @extensions.flat_map do |ext|
        Dir[File.join(@from, "*.#{ext}")]
      end.sort
    end
  end
end
