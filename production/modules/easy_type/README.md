[![Enterprise Modules](https://raw.githubusercontent.com/enterprisemodules/public_images/master/banner1.jpg)](https://www.enterprisemodules.com)

#### Table of Contents

1. [Overview](#overview)
2. [License](#license)
4. [Setup](#setup)
  * [Requirements](#requirements)
  * [Installing the easy_type module](#installing-the-easy_type-module)
7. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module is a base library for many of the puppet module from [Enterprise Modules](https://www.enterprisemodules.com). It contains mostly ruby code that allows you to implement puppet types and providers with great(er) ease.

## License

This is a commercially licensed module. But you can use the module on VirtualBox based development systems for **FREE**. When used on **real** systems a license is required.

You can license our modules in multiple ways. Our basic licensing model requires a subscription per node. But [contact](https://www.enterprisemodules.com/company/contact/) us for details.

Check the [License](https://forge.puppet.com/enterprisemodules/easy_type/license) for details.


## Setup


### Requirements

The `easy_type` module requires:

- Puppet version 3.0 or higher. Can be Puppet Enterprise or Puppet Open Source
- A valid Enterprise Modules license for usage.
- Runs on most Linux systems.
- Runs on Solaris

### Installing the easy_type module

To install these modules, you can use a `Puppetfile`

```
mod 'enterprisemodules/easy_type'               ,'2.3.x'
```

Then use the `librarian-puppet` or `r10K` to install the software.

You can also install the software using the `puppet module`  command:

```
puppet module install enterprisemodules-easy_type
```

## Limitations

This module runs on Solaris and most Linux versions. It requires a puppet version higher than 4. The module does **NOT** run on windows systems.
