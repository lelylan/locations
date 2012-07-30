module ActiveModel
  module Validations
    class OwnedValidator < ActiveModel::EachValidator
      include Lelylan::Search::URI

      def initialize(options)
        options.reverse_merge!(:message => 'URI not existing or not owned.')
        super(options)
      end

      def validate_each(record, attribute, value)
        validate_owner(record, attribute, [value]) if value.kind_of? String
        validate_owner(record, attribute, value)   if value.kind_of? Array
      end

      # Validate that the URIs I'm trying to connect belongs to the resource owner
      def validate_owner(record, attribute, uris) 
        klass    = attribute == :devices ? Device : Location
        ids      = find_ids(uris)
        real     = nil
        expected = nil

        if (klass == Device)
          owner_id = Moped::BSON::ObjectId record.resource_owner_id
          ids      = ids.map {|id| Moped::BSON::ObjectId(id) }
          real     = klass.in(id: ids).where(resource_owner_id: owner_id)
          expected = klass.in(id: ids)
        else
          real     = klass.where(id: ids).where(resource_owner_id: record.resource_owner_id.to_s)
          expected = klass.where(id: ids)
        end

        info = ' IDs are ' + (expected.map(&:id) - real.map(&:id)).join(',') + '.'

        record.errors.add(attribute, options.fetch(:message) + info) if not real.count == expected.count
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
      # * <tt>:message</tt> - A custom error message (default is: 'is not a valid URL').
      # * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute is +nil+ (default is +false+).
      # * <tt>:allow_blank</tt> - If set to true, skips this validation if the attribute is blank (default is +false+).

      def validates_uri(*attr_names)
        validates_with UriValidator, _merge_attributes(attr_names)
      end
    end
  end
end
