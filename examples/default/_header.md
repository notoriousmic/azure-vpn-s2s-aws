# Default Example — Greenfield S2S VPN

Creates a new AWS VPC + VPG and connects to a new Azure VNet with:

- Auto-generated pre-shared keys using `random_password`
- Default VPN Gateway SKU (`VpnGw2AZ`)
- Active-active Azure VPN Gateway with BGP
- 4 IPsec tunnels for full redundancy
