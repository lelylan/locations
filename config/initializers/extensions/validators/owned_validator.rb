module ActiveModel
  module Validations
    class OwnedValidator < ActiveModel::EachValidator
      include Lelylan::Search::URI

      def initialize(options)
        options.reverse_merge!(:message => "A location URI on parent or contained locations is not owned.")
        super(options)
      end

      def validate_each(record, attribute, value)
        validate_owner(record, attribute, [value]) if value.kind_of? String
        validate_owner(record, attribute, value)   if value.kind_of? Array
      end

      def validate_owner(record, attribute, uris) 
        ids = find_ids(uris)
        real     = Location.where(id: ids).where(created_from: record.created_from).count
        expected = Location.where(id: ids).count

        if not real == expected
          record.errors.add(attribute, options.fetch(:message))
        end
      end
    end

    module ClassMethods
      # Validates whether the value of the specified attribute has been created from the same user
      # who has created the resource we are using right now.
      #
      #   class Unicorn
      #     include ActiveModel::Validations
      #     attr_accessor :homepage,
      #     validates_owner :homepage
      #   end
      # Configuration options:
      # * <tt>:message</tt> - A custom error message (default is: "is not a valid URL").
      # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute is +nil+ (default is +false+).
      # * <tt>:allow_blank</tt> - If set to true, skips this validation if the attribute is blank (default is +false+).

      def validates_uri(*attr_names)
        validates_with UriValidator, _merge_attributes(attr_names)
      end
    end
  end
end
