#For Admin Tenant
import-module az
connect-azaccount
Get-AzTenant #get tenant id

#create or use an existinng builtin group to grant management permissions from client tenant.  Get the id
(Get-AzADGroup -DisplayName 'AdminAgents').id

#Set the role for the subscription to be applied to the resources in that subscriuption.  get roledefinitionid
(Get-AzRoleDefinition -Name 'Contributor').id

#For Customer Tenant

connect-azaccount

#check if you have the right subscription selected
get-azcontext

#, if not, select the right subscription first, lookup the current subscriptions in this tenant:
get-azsubscription

#now set the context 
Set-AzContext -Subscription <subscriptionId>

#modify json file accordingly
New-AzDeployment -Name LightHouse -Location locale -TemplateFile "%path to DelegatedManagementtemplate.json%" -TemplateParameterFile "%path to DelegatedManagementparameters.json%" -Verbose

#############################################################################################################
#below are the 2 files you'll need to create 2 separate files
#delegatedmanagementtemplate.json
{
    "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "mspName": {
            "type": "string",
            "metadata": {
                "description": "Specify the Managed Service Provider name"
            }
        },
        "mspOfferDescription": {
            "type": "string",
            "metadata": {
                "description": "Name of the Managed Service Provider offering"
            }
        },
        "managedByTenantId": {
            "type": "string",
            "metadata": {
                "description": "Specify the tenant id of the Managed Service Provider"
            }
        },
        "authorizations": {
            "type": "array",
            "metadata": {
                "description": "Specify an array of objects, containing tuples of Azure Active Directory principalId, a Azure roleDefinitionId, and an optional principalIdDisplayName. The roleDefinition specified is granted to the principalId in the provider's Active Directory and the principalIdDisplayName is visible to customers."
            }
        }              
    },
    "variables": {
        "mspRegistrationName": "[guid(parameters('mspName'))]",
        "mspAssignmentName": "[guid(parameters('mspName'))]"
    },
    "resources": [
        {
            "type": "Microsoft.ManagedServices/registrationDefinitions",
            "apiVersion": "2019-06-01",
            "name": "[variables('mspRegistrationName')]",
            "properties": {
                "registrationDefinitionName": "[parameters('mspName')]",
                "description": "[parameters('mspOfferDescription')]",
                "managedByTenantId": "[parameters('managedByTenantId')]",
                "authorizations": "[parameters('authorizations')]"
            }
        },
        {
            "type": "Microsoft.ManagedServices/registrationAssignments",
            "apiVersion": "2019-06-01",
            "name": "[variables('mspAssignmentName')]",
            "dependsOn": [
                "[resourceId('Microsoft.ManagedServices/registrationDefinitions/', variables('mspRegistrationName'))]"
            ],
            "properties": {
                "registrationDefinitionId": "[resourceId('Microsoft.ManagedServices/registrationDefinitions/', variables('mspRegistrationName'))]"
            }
        }
    ],
    "outputs": {
        "mspName": {
            "type": "string",
            "value": "[concat('Managed by', ' ', parameters('mspName'))]"
        },
        "authorizations": {
            "type": "array",
            "value": "[parameters('authorizations')]"
        }
    }
}

#DelegatedManagementParameters.json

{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "mspName": {
            "value": "%mspname%"
        },
        "mspOfferDescription": {
            "value": "%msp offer description"
        },
        "managedByTenantId": {
            "value": "%admin tenant ID"
        },
        "authorizations": {
            "value": [
                {
                    "principalId": "%principal ID%",
                    "roleDefinitionId": "%role definition id%",
                    "principalIdDisplayName": "AdminAgents"
                }
            ]
        }
    }
}

