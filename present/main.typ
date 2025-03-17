#import "@preview/slydst:0.1.4": *
#import "@preview/diagraph:0.3.2": render

#show: slides.with(
  title: "Chainlink CCIP for Cardano",
  subtitle: "From Solidity to Aiken: Patterns and Practices",
  authors: "Kasey White",
  date: "March 2025",
  title-color: rgb("#3154bf"),
  layout: "medium",
)

#show raw: set block(fill: silver.lighten(65%), width: 100%, inset: 1em)

= Chainlink CCIP

== What is Chainlink CCIP?

- Cross-chain Interoperability Protocol (CCIP) facilitates the transmission of messages containing data and value across different blockchains
#linebreak()
- Said messages can be used to call contracts on other chains
#linebreak()
- The Messages follow the EVM2ANY format with the binary abi encoding from EVM
#linebreak()
- Messages are validated by chainlink validator network and are double checked
  by a multisig Risk management set of nodes

== Architecture Layout

#render(
  "digraph { 
    Ethereum -> Chainlink_Validator_Network
    Chainlink_Validator_Network -> Cardano
    Risk_Management_Nodes -> Cardano
   }",
   edges: (
    "Ethereum": ("Chainlink_Validator_Network": "Messages & Value"),
    "Chainlink_Validator_Network": (
      "Cardano": "Validated Data"
    ),
    "Risk_Management_Nodes" : ("Cardano": "Approve")
    )
)

== CCIP Message Structure

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *Solidity Message Structure*
    ```solidity
    struct Client {
      bytes32 sender;
      uint64 nonce;
      uint256 sourceChainSelector;
      address receiver;
      bytes data;
      EVMTokenAmount[] tokenAmounts;
    }
    struct EVMTokenAmount {
      address token;
      uint256 amount;
    }
    ```
  ],
  [
    *Aiken Equivalent (Preview)*
    ```aiken
    type Client {
      sender: ByteArray,
      nonce: Int,
      source_chain_selector: Int,
      receiver: ByteArray,
      data: ByteArray,
      token_amounts: List<TokenAmount>,
    }
    type TokenAmount {
      token: ByteArray,
      amount: Int,
    }
    ```
  ]
)

= Converting Solidity to Aiken

== Common patterns in Solidity

- Proxy contracts
#linebreak()
- State mapping i.e. (address => struct)
#linebreak()
- abi encoding of structs and keccak_256 hashing
#linebreak()
- explicit integer sizes
#linebreak()
- Merkle Trees

== Translating Solidity Patterns to Aiken

*Proxy Contracts*
- Direct script lookup via `scriptContext` enables action proxying
- Memory in UTXOs with NFTs - easier to manage than Solidity's address storage
#linebreak()

*State Mapping*
- Per-UTXO approach for mapping elements
- Transactions only include relevant UTXOs
- Space costs managed via Merkle trees or element lists in single UTXOs
#linebreak()

*ABI Encoding & Hashing*
- Custom encoding logic required in Aiken
- Native keccak_256 builtin matches Solidity functionality

== Translating Solidity Patterns to Aiken (Cont.)

*Integer Handling*
- Aiken integers have unlimited size - no overflow concerns
- Use fixed-size bytearrays for bitwise operations
#linebreak()

*Merkle Trees*
- We have existing merkle tree implementations in Aiken
- Was tackled in previous Aiken projects (Fortuna)
#linebreak()

*Implementation Challenges*
- Global state UTXO contention (solutions in development)
- Recursion makes looping more expensive than Solidity
- Focus on business logic over gas optimization
- Rely on unit/property testing for correctness



= Summary

== Summary

- Since there's little to no effort or expertise on Cardano from Chainlink, we can take action ourselves to do the bulk of the effort
#linebreak()

- The work used to do conversions can apply to other cross-chain protocols and standards like LayerZero, Wormhole, or the Token Bridge Standards Alliance
#linebreak()

- We now have concrete ways to transform Solidity to Aiken contracts to emulate the same behavior (the newer builtins added recently help a lot)

= Appendix
== CCIP Terminology

#table(
  columns: (auto, 1fr),
  inset: 10pt,
  align: left,
  stroke: 0.5pt,
  [*Term*], [*Definition*],
  [EVM2ANY format], [A standardized message format that enables communication between EVM-based chains and non-EVM chains (like Cardano). It provides a common structure for cross-chain data exchange.],
  [Binary ABI encoding], [The Application Binary Interface encoding method used by Ethereum to serialize and deserialize data. CCIP uses this encoding for consistency across different blockchain environments.],
  [Validator network], [A decentralized set of Chainlink nodes that verify cross-chain messages, ensuring data integrity and preventing malicious transactions.],
)

== Contact & Resources

- *Email*: byword-hitters.9h\@icloud.com
#linebreak()
- *Twitter*: \@Microproofs
#linebreak()
- *GitHub*: github.com/Microproofs

== Project Links

- #link("https://github.com/aiken-lang/chainlink-ccip")[Aiken Prototype]
#linebreak()
- #link("https://discord.gg/fF4w9vkW")[Pragma Discord]
#linebreak()
- #link("https://docs.chain.link/ccip")[Chainlink CCIP Documentation]
#linebreak()
- #link("https://aiken-lang.org/installation-instructions")[Aiken Language Documentation]

