parent.newparam(:disable_corrective_change) do
  include EasyType
  desc <<-DESC
  Disable the modification of a resource when Puppet decides it is a corrective change.

  (requires easy_type V2.11.0 or higher)

  When using a Puppet Server, Puppet knows about adaptive and corrective changes. A corrective change
  is when Puppet notices that the resource has changed, but the catalog has not changed. This can occur
  for example, when a user, by accident or willingly, changed something on the system that Puppet is
  managing. The normal Puppet process then repairs this and puts the resource back in the state as defined
  in the catalog. This process is precisely what you want most of the time, but not always. This can
  sometimes also occur when a hardware or network error occurs. Then Puppet cannot correctly determine
  the current state of the system and thinks the resource is changed, while in fact, it is not. Letting
  Puppet recreate remove or change the resource in these cases, is NOT wat you want.
  
  Using the `disable_corrective_change` parameter, you can disable corrective changes on the current resource.
  
  Here is an example of this:

      crucial_resource {'be_carefull':
        ...
        disable_corrective_change => true,
        ...
      }

  When a corrective ensure does happen on the resource Puppet will not modify the resource 
  and signal an error:  

          Error: Corrective change present requested by catalog, but disabled by parameter disable_corrective_change
          Error: /Stage[main]/Main/Crucial_resource[be_carefull]/parameter: change from '10' to '20' failed: Corrective change present requested by catalog, but disabled by parameter disable_corrective_change. (corrective)


  DESC

  data_type 'Variant[Boolean, Array[String[1]]]'

  defaultto false
end
