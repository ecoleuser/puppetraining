#
# See the file "LICENSE" for the full license governing this code.
#
module EasyType

  #
  # This class is an easy way to create a Puppet task that can:
  #  - list
  #  - get the current status of a named resource
  #  - create a resource
  #  - remove a resouce
  #
  class ResourceTask

    def initialize(type, name_attribute = :name )
      @params        = JSON.parse(STDIN.read)
      @action        = @params.fetch('action') {'list'}
      @name          = @params[name_attribute]
      @type          = type
      @resource_type = Puppet::Type.type(type)
      @options       = @params.fetch('options') {{}}
      @options.merge!(:name => @name)
    end

    #
    # Get all resources of the named type
    #
    def all_resources
      @resource_type.instances.collect { |e| to_data(e) }
    end

    #
    # Get the resource who's name is equal to the specfied name
    #
    def resource
      value = @resource_type.instances.find {|e| e.to_hash[:name] == @name }
      raise Puppet::Error, "Resource #{@type}[#{@name}] not found." if value.nil?
      value
    end

    def to_data(value)
      value.to_resource.to_hash.delete_if { |_k, v| v == :absent } 
    end

    #
    # Execute the requested action
    #
    def execute
      case @action
      when 'list'
        all_resources
      when 'status'
        to_data(resource)
      when 'create'
        instance = @resource_type.new({ensure: :present}.merge(@options))
        instance.provider.create
        to_data(resource)
      when 'remove'
        instance = resource
        instance.provider.destroy
        "#{instance} removed."
      else
        fail 'Invalid action specified. Valid values are list, status, create and remove.'
      end
    end
  end
end

