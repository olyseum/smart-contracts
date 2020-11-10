# <img src="logo.png" alt="Olyseum" width="400px">

[Olyseum](https://corporate.olyseum.com/) is a blockchain-based social platform that provides stars a way to monetize their activity and to reward their fansbase's engagement, allowing fans access exclusive experiences in a social-marketplace. Olyseum uses online advertising, as well as the sale of exclusive experiences, products and services, to allow stars earn part of the revenue they generate thanks to every follower both in Olyseum and in the rest of their current social networks, and reward their best fans with a token that provides access to them, improving the quality of the fan-star relationship.

> NOTE: For more details, please read our whitepaper [here](https://doc.olyseum.com/Olyseum-wpaper_3.1.pdf).

## Getting Started

This repository contains the code necessary to create the [OLY token](https://etherscan.io/token/0x6595b8fd9c920c81500dca94e53cdc712513fb1f) and contracts used by Olyseum platform.

### Deployed contracts from Olyseum

| Contract | sha256 |
|---|---|
| CampaignFund.sol | b6c483d15ffe18e72706533008f8586a6d3057db5846ac94cb594e5a587e0285 |
| MultiSigWallet.sol | aef60ea24446eab9cd08085224fb049b7f19d97a753cbd5252fc930df7a797dc |
| OlyToken.sol | e41d226876b284a9e0dbb1acc14e2db273f65c6045524e77eb9a2e1de2baa249 |

### Deployed contracts from OpenZeppelin (install versions in package.json with yarn)

| Contract | sha256 |
|---|---|
| AdminUpgradeabilityProxy.sol | 368840424aed7aff2461da259bdb8ba7e25e5576fea67fccef0ad5abb4191c9d |

## Audit

Contracts were audited by [Coinspect](https://coinspect.com/). The report can be found [here](https://doc.olyseum.com/OlyToken_Smart_Contract_Auditv0923-998d8fb68144ee44dda722703fe53ae4.pdf).
