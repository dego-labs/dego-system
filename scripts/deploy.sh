echo "deploy begin....."

TF_CMD=node_modules/.bin/truffle-flattener

# echo "" >  ./deployments/DandyToken.full.sol
# cat  ./scripts/head.sol >  ./deployments/DandyToken.full.sol
# $TF_CMD ./contracts/dandy/DandyToken.sol >>  ./deployments/DandyToken.full.sol 

# echo "" >  ./deployments/GegoToken.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegoToken.full.sol
# $TF_CMD ./contracts/nft/GegoToken.sol >>  ./deployments/GegoToken.full.sol 


# echo "" >  ./deployments/GegoTokenV2.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegoTokenV2.full.sol
# $TF_CMD ./contracts/nft/GegoTokenV2.sol >>  ./deployments/GegoTokenV2.full.sol 


# echo "" >  ./deployments/GegoFactory.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegoFactory.full.sol
# $TF_CMD ./contracts/nft/GegoFactory.sol >>  ./deployments/GegoFactory.full.sol 


# echo "" >  ./deployments/DividentReward.full.sol
# cat  ./scripts/head.sol >  ./deployments/DividentReward.full.sol
# $TF_CMD ./contracts/reward/DividentReward.sol >>  ./deployments/DividentReward.full.sol 

echo "" >  ./deployments/AuctionHubReward.full.sol
cat  ./scripts/head.sol >  ./deployments/AuctionHubReward.full.sol
$TF_CMD ./contracts/reward/AuctionHubReward.sol >>  ./deployments/AuctionHubReward.full.sol 

echo "" >  ./deployments/AuctionHubRewardProxy.full.sol
cat  ./scripts/head.sol >  ./deployments/AuctionHubRewardProxy.full.sol
$TF_CMD ./contracts/reward/AuctionHubRewardProxy.sol >>  ./deployments/AuctionHubRewardProxy.full.sol 

# echo "" >  ./deployments/GeneralNFTReward.full.sol
# cat  ./scripts/head.sol >  ./deployments/GeneralNFTReward.full.sol
# $TF_CMD ./contracts/reward/GeneralNFTReward.sol >>  ./deployments/GeneralNFTReward.full.sol 

# echo "" >  ./deployments/NFTReward.full.sol
# cat  ./scripts/head.sol >  ./deployments/NFTReward.full.sol
# $TF_CMD ./contracts/reward/NFTReward.sol >>  ./deployments/NFTReward.full.sol 

# echo "" >  ./deployments/NFTRewardKCS.full.sol
# cat  ./scripts/head.sol >  ./deployments/NFTRewardKCS.full.sol
# $TF_CMD ./contracts/reward/NFTRewardKCS.sol >>  ./deployments/NFTRewardKCS.full.sol 

# echo "" >  ./deployments/NFTRewardBot1.full.sol
# cat  ./scripts/head.sol >  ./deployments/NFTRewardBot1.full.sol
# $TF_CMD ./contracts/reward/NFTRewardBot1.sol >>  ./deployments/NFTRewardBot1.full.sol 

# echo "" >  ./deployments/NFTRewardBot2.full.sol
# cat  ./scripts/head.sol >  ./deployments/NFTRewardBot2.full.sol
# $TF_CMD ./contracts/reward/NFTRewardBot2.sol >>  ./deployments/NFTRewardBot2.full.sol 

# echo "" >  ./deployments/NFTPlayerOpenSales.full.sol
# cat  ./scripts/head.sol >  ./deployments/NFTPlayerOpenSales.full.sol
# $TF_CMD ./contracts/sales/NFTPlayerOpenSales.sol >>  ./deployments/NFTPlayerOpenSales.full.sol 

# echo "" >  ./deployments/NFTMarket.full.sol
# cat  ./scripts/head.sol >  ./deployments/NFTMarket.full.sol
# $TF_CMD ./contracts/sales/NFTMarket.sol >>  ./deployments/NFTMarket.full.sol 


# echo "" >  ./deployments/GegoBaseProxy.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegoBaseProxy.full.sol
# $TF_CMD ./contracts/nft/GegoBaseProxy.sol >>  ./deployments/GegoBaseProxy.full.sol 

# echo "" >  ./deployments/GegoGradeUpProxy.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegoGradeUpProxy.full.sol
# $TF_CMD ./contracts/nft/GegoGradeUpProxy.sol >>  ./deployments/GegoGradeUpProxy.full.sol 


# echo "" >  ./deployments/GegoFactoryV2.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegoFactoryV2.full.sol
# $TF_CMD ./contracts/nft/GegoFactoryV2.sol >>  ./deployments/GegoFactoryV2.full.sol 


# echo "" >  ./deployments/GegeTLevelUpProxy.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegeTLevelUpProxy.full.sol
# $TF_CMD ./contracts/nft/GegeTLevelUpProxy.sol >>  ./deployments/GegeTLevelUpProxy.full.sol 


# echo "" >  ./deployments/GegoFactoryBSC.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegoFactoryBSC.full.sol
# $TF_CMD ./contracts/nft/GegoFactoryBSC.sol >>  ./deployments/GegoFactoryBSC.full.sol 

# echo "" >  ./deployments/GegoMigratorProxy.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegoMigratorProxy.full.sol
# $TF_CMD ./contracts/nft/GegoMigratorProxy.sol >>  ./deployments/GegoMigratorProxy.full.sol 

# echo "" >  ./deployments/GegoMintProxy.full.sol
# cat  ./scripts/head.sol >  ./deployments/GegoMintProxy.full.sol
# $TF_CMD ./contracts/nft/GegoMintProxy.sol >>  ./deployments/GegoMintProxy.full.sol 

echo "" >  ./deployments/DegoDividend.full.sol
cat  ./scripts/head.sol >  ./deployments/DegoDividend.full.sol
$TF_CMD ./contracts/dividend/DegoDividend.sol >>  ./deployments/DegoDividend.full.sol 

echo "" >  ./deployments/DegoDividendProxy.full.sol
cat  ./scripts/head.sol >  ./deployments/DegoDividendProxy.full.sol
$TF_CMD ./contracts/dividend/DegoDividendProxy.sol >>  ./deployments/DegoDividendProxy.full.sol 

echo "" >  ./deployments/DegoDividendTeam.full.sol
cat  ./scripts/head.sol >  ./deployments/DegoDividendTeam.full.sol
$TF_CMD ./contracts/dividend/DegoDividendTeam.sol >>  ./deployments/DegoDividendTeam.full.sol

echo "" >  ./deployments/DegoDividendTeamProxy.full.sol
cat  ./scripts/head.sol >  ./deployments/DegoDividendTeamProxy.full.sol
$TF_CMD ./contracts/dividend/DegoDividendTeamProxy.sol >>  ./deployments/DegoDividendTeamProxy.full.sol



# echo "" >  ./deployments/ChristmasDegoDividend.full.sol
# cat  ./scripts/head.sol >  ./deployments/ChristmasDegoDividend.full.sol
# $TF_CMD ./contracts/christmas/ChristmasDegoDividend.sol >>  ./deployments/ChristmasDegoDividend.full.sol 

# echo "" >  ./deployments/ChristmasDegoDividendProxy.full.sol
# cat  ./scripts/head.sol >  ./deployments/ChristmasDegoDividendProxy.full.sol
# $TF_CMD ./contracts/christmas/ChristmasDegoDividendProxy.sol >>  ./deployments/ChristmasDegoDividendProxy.full.sol 

# echo "" >  ./deployments/ChristmasDegoDividendTeam.full.sol
# cat  ./scripts/head.sol >  ./deployments/ChristmasDegoDividendTeam.full.sol
# $TF_CMD ./contracts/christmas/ChristmasDegoDividendTeam.sol >>  ./deployments/ChristmasDegoDividendTeam.full.sol

# echo "" >  ./deployments/ChristmasDegoDividendTeamProxy.full.sol
# cat  ./scripts/head.sol >  ./deployments/ChristmasDegoDividendTeamProxy.full.sol
# $TF_CMD ./contracts/christmas/ChristmasDegoDividendTeamProxy.sol >>  ./deployments/ChristmasDegoDividendTeamProxy.full.sol

echo "deploy end....."
echo "success"