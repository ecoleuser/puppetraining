#
# See the file "LICENSE" for the full license governing this code.
#
module EasyType

    #
    # This class is an easy way extract all specfied resource information from a database
    #
    # The resource_types is hash of the name of the puppet type to use for extraction and a closure
    # to filter out any properties or entries you don't want.
    #
    class ExtractTask
  
      def initialize(resource_types)
        @resource_types = resource_types
      end
      
      def to_data(value)
        resource_data = value.to_resource.to_hash
        # Remove any proprty that is absent and the standard Puppet properties loglevel and provider
        resource_data.delete_if { |k, v| [:loglevel, :provider].include?(k) || v == :absent }
        {resource_data.delete(:name) => resource_data}
      end
  
      #
      # Fetch all known data from resources
      #
      def execute
        data = {}
        @resource_types.each do | type, options|
          filter = options.delete(:filter)
          key    = options.delete(:key)
          raise "Unsupported options #{options.keys.join(', ')} provided" if options != {}
          resource_class = Puppet::Type.type(type)
          data[key] = resource_class.instances.collect do |entry| 
            entry_data = to_data(entry)
            filter ? filter.call(entry_data) : entry_data
          end.compact.reduce({}, :merge)
        end
        data
      end
    end
  end
  
  