parent.newparam(:disable_corrective_ensure) do
  include EasyType
  desc <<-DESC
  Disable the creation or removal of a resource when Puppet decides is a corrective change.

  (requires easy_type V2.11.0 or higher)

  When using a Puppet Server, Puppet knows about adaptive and corrective changes. A corrective change
  is when Puppet notices that the resource has changed, but the catalog has not changed. This can occur
  for example, when a user, by accident or willingly, changed something on the system that Puppet is
  managing. The normal Puppet process then repairs this and puts the resource back in the state as defined
  in the catalog. This process is precisely what you want most of the time, but not always. This can
  sometimes also occur when a hardware or network error occurs. Then Puppet cannot correctly determine
  the current state of the system and thinks the resource is changed, while in fact, it is not. Letting
  Puppet recreate remove or change the resource in these cases, is NOT wat you want.
  
  Using the `disable_corrective_ensure` parameter, you can disable corrective ensure present or ensure absent actions on the current resource.
  
  Here is an example of this:

      crucial_resource {'be_carefull':
        ensure                    => 'present',
        ...
        disable_corrective_ensure => true,
        ...
      }

  When a corrective ensure does happen on the resource Puppet will not create or remove the resource 
  and signal an error:  

          Error: Corrective ensure present requested by catalog, but disabled by parameter disable_corrective_ensure.
          Error: /Stage[main]/Main/Crucial_resource[be_carefull]/ensure: change from 'absent' to 'present' failed: Corrective ensure present requested by catalog, but disabled by parameter disable_corrective_ensure. (corrective)

  DESC

  data_type 'Boolean'

  defaultto false
end
