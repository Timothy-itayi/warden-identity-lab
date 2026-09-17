
# WARDEN Identity Operations Lab

Disposable Azure Active Directory lab built with Terraform and PowerShell.

Core demo:

1. generate a real account lockout
2. collect Event ID 4740 with Azure Monitor Agent
3. detect it with KQL
4. fire an Azure Monitor alert
5. create a Freshdesk ticket through an Action Group email
6. investigate and resolve the account safely
7. destroy the Azure lab when finished
