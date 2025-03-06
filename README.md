# ddev-oxid

ddev-oxid is a DDEV add-on designed to streamline the installation and configuration of the OXID eShop within a DDEV environment. It automates common setup tasks, making it easier and faster for developers to get a fully configured OXID eShop up and running locally.

## Why use ddev-oxid?

- **Simplified Installation:**  
  Automatically installs the OXID eShop via Composer and sets up the environment with a single interactive command.

- **Automated Configuration:**  
  Runs the necessary OXID CLI commands to configure your shop, including shop setup, demo data installation, administrator creation, license addition, and theme activation.

- **Optimized for DDEV:**  
  Leverages DDEV’s containerized environment, ensuring consistent configuration and dependencies, and uses DDEV environment variables (e.g., for dynamic shop URL generation).

- **Customizable and Interactive:**  
  The add-on provides interactive prompts to select the OXID version, set database parameters (defaulting to DDEV’s standard values), and optionally run additional configuration steps.


## Requirements

- **DDEV:**  
  Version 1.23.5 or above is recommended.

- **Composer:**  
  Composer must be installed on your system since ddev-oxid uses Composer to install the OXID eShop.

- **PHP:**  
  Ensure that the PHP version configured in DDEV matches the requirements of the selected OXID eShop version (for example, OXID 7.x typically requires PHP 7.2 or 7.4).

- **Git:**  
  Git is required for fetching the add-on from the repository.

- **Apache FPM:**  
    This add-on is configured to run with Apache FPM. The document root is set to `htdocs/source` for proper serving of the OXID eShop.


## How to Use

### Installation

1. **Install the Add-on:**

   For DDEV v1.23.5 or above, run:

   ```shell
   ddev add-on get maexware-danny/ddev-oxid

Make sure your .ddev/config.yaml is configured with:

docroot: htdocs/source
webserver_type: apache-fpm


htdocs should be empty
   
