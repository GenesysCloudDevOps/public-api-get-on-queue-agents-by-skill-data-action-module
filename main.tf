resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "properties" = {
            "QUEUE_ID" = {
                "description" = "Queue ID",
                "type" = "string"
            },
            "ROUTING_STATUS" = {
                "description" = "Routing status",
                "type" = "string"
            },
            "SKILL" = {
                "description" = "Skill names",
                "type" = "string"
            }
        },
        "required" = [
            "QUEUE_ID",
            "ROUTING_STATUS",
            "SKILL"
        ],
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "additionalProperties" = true,
        "description" = "Response",
        "properties" = {
            "iAgents" = {
                "description" = "Count of agents up to 25",
                "type" = "integer"
            }
        },
        "title" = "Response",
        "type" = "object"
    })
    
    config_request {
        request_template     = "$${input.rawRequest}"
        request_type         = "GET"
        request_url_template = "/api/v2/routing/queues/$${input.QUEUE_ID}/members?skills=$esc.url($${input.SKILL})&routingStatus=$${input.ROUTING_STATUS}&joined=true"
        headers = {
			UserAgent = "PureCloudIntegrations/1.0"
			Content-Type = "application/json"
		}
    }

    config_response {
        success_template = "{\n   \"iAgents\": $${iAgents}\n}"
        translation_map = { 
			iAgents = "$.entities.size()"
		}
               
    }
}