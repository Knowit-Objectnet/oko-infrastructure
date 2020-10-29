# Keycloak Realm
The files included in this folder is used to instantiate the Keycloak realm. It is dependant upon the [Keycloak custom terraform provider](https://github.com/mrparkers/terraform-provider-keycloak).

## Setup
In order for *terraform apply* to work, you will first have to install the custom provider mentioned above. The releases can be found [here](https://github.com/mrparkers/terraform-provider-keycloak/releases). Instructions for installing third-party providers can be found [here](https://www.terraform.io/docs/configuration/providers.html#third-party-plugins).


You will also need to configure a client so that terraform can connect to your keycloak instance. We have chosen to get access through the client credentials grant setup. Instructions for setup can be found [here](https://mrparkers.github.io/terraform-provider-keycloak/#keycloak-setup). Client secret can be found in Keycloak, whilst the URL can be found in AWS (if not already chosen).
