#import "@preview/slydst:0.1.4": *

#show: slides.with(
  title: "Navigating Chainlink CCIP with Aiken",
  subtitle: "Stuff",
  authors: "Kasey White",
)

#show raw: set block(fill: silver.lighten(65%), width: 100%, inset: 1em)

== Outline

#outline()

= Chainlink CCIP

== What is Chainlink CCIP?

- Cross-chain Interoperability Protocol (CCIP) is used to relay 
Messages that relay data and value between different blockchains
- Said messages can be used to call contracts on other chains
- The Messages follow the EVM2ANY format with the binary abi encoding from EVM
- Messages are validated by chainlink validator network and are double checked
  by a multisig Risk management set of nodes


= Converting Solidity to Aiken

== Common patterns in Solidity

- Proxy contracts
- State mapping i.e. (address => struct)
- abi encoding of structs and keccak_256 hashing
- explicit integer sizes


== Translating Solidity Patterns to Aiken

- Stuff here

= Summary

== Summary

- Since there's little to not effort or expertise on Cardano from Chainlink
  We can take action ourselves to do the bulk of the effort
- The work used to do conversions can apply to other cross-chain protocols
  and standards
- We now have a concrete where to transform Solidity to Aiken contracts to 
  emulate the same behavior (the newer builtins added recently help a lot)
