#blue forest trust commands
netdom trust domain.blueforest.com /Domain:domain.redforest.com /Add /UserD:administrator@domain.redforest.com /PasswordD:* /UserO:administrator@domain.blueforest.com /PasswordO:*

netdom trust domain.blueforest.com /domain:domain.redforest.com /ForestTRANsitive:Yes

netdom trust domain.blueforest.com /domain:domain.redforest.com /EnableSIDHistory:Yes

netdom trust domain.blueforest.com /domain: domain.redforest.com /EnablePIMTrust:Yes

netdom trust domain.blueforest.com /domain: domain.redforest.com /Quarantine:No

