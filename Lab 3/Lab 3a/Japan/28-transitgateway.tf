# # Required: Read the São Paulo TGW ID from its remote state
# # Adjust backend config (bucket/key/region/etc.) to match your São Paulo setup
# data "terraform_remote_state" "saopaulo" {
#   backend = "s3" # or "remote" for Terraform Cloud, etc.

#   config = {
#     bucket = "arma-brazil-backend-lt"
#     key    = "01.27.26/terraform.tfstate" # e.g. "env:/saopaulo/terraform.tfstate"
#     region = "sa-east-1"
#     # dynamodb_table = "terraform-locks"   # if using
#     # profile        = "your-profile"      # if needed
#   }
# }

# Explanation: edo Station is the hub—Tokyo is the data authority.
resource "aws_ec2_transit_gateway" "edo_tgw01" {
  description = "edo-tgw01 (Tokyo hub)"
  tags        = { Name = "edo-tgw01" }
}

# Explanation: edo connects to the Tokyo VPC—this is the gate to the medical records vault.
resource "aws_ec2_transit_gateway_vpc_attachment" "edo_attach_tokyo_vpc01" {
  transit_gateway_id = aws_ec2_transit_gateway.edo_tgw01.id
  vpc_id             = aws_vpc.edo_vpc01.id
  subnet_ids         = aws_subnet.edo_private_subnets[*].id
  tags               = { Name = "edo-attach-tokyo-vpc01" }
}

# # Explanation: edo opens a corridor request to gru—compute may travel, data may not.
# resource "aws_ec2_transit_gateway_peering_attachment" "edo_to_gru_peer01" {
#   transit_gateway_id      = aws_ec2_transit_gateway.edo_tgw01.id
#   peer_region             = "sa-east-1"
#   peer_transit_gateway_id = data.terraform_remote_state.saopaulo.outputs.gru_tgw_id

#   tags = {
#     Name              = "edo-to-gru-peer01"
#     "peering:from"    = "tokyo"
#     "peering:to"      = "saopaulo"
#     "peering:purpose" = "compute-access-only"
#   }
# }

