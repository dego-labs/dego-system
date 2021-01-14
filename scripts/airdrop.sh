echo "deploy begin....."

TF_CMD=node_modules/.bin/truffle-flattener

echo "" >  ./deployments/DegoTokenAirDrop.full.sol
cat  ./scripts/head.sol >  ./deployments/DegoTokenAirDrop.full.sol
$TF_CMD ./contracts/airdrop/DegoTokenAirDrop.sol >>  ./deployments/DegoTokenAirDrop.full.sol 

echo "deploy end....."