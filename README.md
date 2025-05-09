# Lottery
A simple, trustless, and transparent lottery smart contract built with Solidity on the Ethereum blockchain. Anyone can participate by paying a fixed amount of ERC-20 token to enter the lottery. After a set period or number of participants, a winner is randomly selected and receives the entire prize pool.

## Build
```shell
$ forge build
```

## Env
```shell
Get-Content .env | ForEach-Object {
    if ($_ -match "^\s*([^#]\S+)\s*=\s*(.*)\s*$") {
        $varName = $matches[1]
        $varValue = $matches[2] -replace '^"|"$|^''|''$'  # 去除可能的引号
        Set-Item -Path "env:$varName" -Value $varValue
    }
}

echo $env:PRIVATE_KEY
echo $env:RPC_URL
```

## Deploy
```shell
forge script ./script/LotteryScript.s.sol:LotteryScript --rpc-url $env:RPC_URL --private-key $env:PRIVATE_KEY --broadcast
```

## Approve
```shell
cast send --rpc-url $env:RPC_URL --private-key $env:PRIVATE_KEY $env:TOKEN_ADDRESS "approve(address, uint256)" $env:LOTTERY_PROXY $env:APPROVE_AMOUNT
```
## Purchase
```shell
cast send --rpc-url $env:RPC_URL --private-key $env:PURCHASE_PRIVATE_KEY $env:LOTTERY_PROXY "purchaseLotteryTicket(address)" $env:PURCHASE_USER
```

## Query
```shell
cast call --rpc-url $env:RPC_URL $env:LOTTERY_PROXY "getLotteryRoundInfo(uint256)(uint256,bool,address)" 1
```

## Address
```
lottery proxy contract deployed at: 0x4aB06ddaf38cCdBEf91579540c5c23888BCA37B4
```
