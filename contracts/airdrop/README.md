# Airdrop  

## Airdrop Reward rules

First the recipients And the amount of the award must have been set up by the administrator.

The amount of the first award that can be received:
```
    reward = amount * 0.2 + amount * 0.8 / 100day * (now - lastRewardTime)
```

The rest of the award can be received:
```
    reward = amount * 0.8 / 100day * (now - lastRewardTime)
```

## Airdrop Contract tests

airdrop(Contract:0x959723872941D1ab5c76fd0cbd8F940147Fe0520)
https://kovan.etherscan.io/tx/0x2990d984e95de6a026bc301b02ab709abf373d8f3691ffde7da61ce59ffed6a0


Dego Token(Contract:0x1fB8dE6bc29241c9e9Ccf63A4dfb439BD03753E8) add a minter
https://kovan.etherscan.io/tx/0x4bfa9780a744ea2d52ea15ba7c02eee6b7c54e86e1908e50eb8eef0693d5b605


Administrator set Whitelist
https://kovan.etherscan.io/tx/0x6a3aa13d2bc46a6cf8785e5cac16b9b72829488896c080165c110333702bd378


Award recipients get first reward
https://kovan.etherscan.io/tx/0x41c36afbf3bb88aa36cbae299a72c3d39994db13b27889323d94a40007d5a35a


Award recipients get second reward
https://kovan.etherscan.io/tx/0x54d4eb0ccf652bffb0c2255466a1fe56223989ee3ad9c7a9634b78beb83f2f40


Administrator add Whitelist
https://kovan.etherscan.io/tx/0x47e8c9efa06d920259b6c231de3b92b6821d3f42c773f36002090656c133da1a


Administrator Removed account from the whitelist
https://kovan.etherscan.io/tx/0xed5b8af16a7490c43b52c2b252df52cc86e3c936a47de25eb2b4fe9f82e35aef

