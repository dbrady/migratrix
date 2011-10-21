require 'yaml'

module Migratrix
  module Loads
    class Yaml < Load
      set_valid_options :filename

      def load(transformed_items)
        File.open(options[:filename], 'w') do |file|
          file.puts transformed_items.to_yaml
        end
      end
    end
  end
end
