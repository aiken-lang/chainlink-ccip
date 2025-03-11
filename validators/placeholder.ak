use aiken/collection/dict.{to_pairs}
use aiken/collection/list
use aiken/crypto.{Hash, Keccak_256}
use cardano/address.{Address, Credential, Script}
use cardano/assets.{PolicyId, to_dict}
use cardano/certificate.{Certificate}
use cardano/governance.{ProposalProcedure, Voter}
use cardano/script_context.{ScriptContext}
use cardano/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction,
}

type RootHash =
  Hash<Keccak_256, Data>

const max_voters = 16

type VoteProgress {
  version: Int,
  accumulated_weight: Int,
  voter_bitmap: ByteArray,
  weight_threshold_met: Bool,
}

type BlessRecord {
  version: Int,
  weight: Int,
  index: ByteArray,
}

type CurseRecord {
  version: Int,
  weight: Int,
  index: ByteArray,
}

type ArmDatum {
  // A curse becomes active after:
  // - accumulatedWeight becomes greater or equal than curseWeightThreshold; or
  // - the owner curses.
  // Once a curse is active, only the owner can lift it.
  Global {
    owner: Credential,
    bless_weight_threshold: Int,
    curse_weight_threshold: Int,
    accumulated_weight: Int,
    version: Int,
    curse_active: Bool,
  }
  TaggedRoots { roots: Pairs<RootHash, VoteProgress> }

  Voter {
    voter: Credential,
    bless_record: BlessRecord,
    curse_record: CurseRecord,
  }
}

pub type SpendEndpoint {
  VoteToBless { roots: List<RootHash> }
}

fn dataify(data: Data) {
  data
}

// @inheritdoc IRMN
// function isCursed() external view returns (bool) {
//   if (s_curseHotVars.numSubjectsCursed == 0) {
//     return false; // happy path costs a single SLOAD
//   } else {
//     return s_potentiallyOutdatedCurseVoteProgressBySubject[GLOBAL_CURSE_SUBJECT].curseActive
//       || s_potentiallyOutdatedCurseVoteProgressBySubject[LEGACY_CURSE_SUBJECT].curseActive;
//   }
// }

validator proxy_arm {
  spend(
    _datum: Option<Data>,
    redeemer: Data,
    utxo: OutputReference,
    self: Transaction,
  ) {
    todo
  }

  else(_: ScriptContext) {
    fail
  }
}

pub fn fold_votes_and_tag_roots(
  own_address: Address,
  vote_value: Data,
  tag_value: Data,
  self: List<Input>,
  weight: Int,
  tag_roots: Output,
  callback,
) {
  when self is {
    [] -> callback(weight, tag_roots)

    [input, ..xs] -> {
      let
        weight,
        tag_roots,
      <-
        fold_votes_and_tag_roots(
          own_address,
          vote_value,
          tag_value,
          xs,
          weight,
          tag_roots,
        )

      if input.output.address == own_address {
        let Input { output: Output { value, datum, .. }, .. } = input

        expect [_, ..rest] = value |> to_dict |> to_pairs

        expect InlineDatum(data) = datum

        if vote_value == dataify(rest) {
          expect Voter { .. } = data

          todo
        } else if tag_value == dataify(rest) {
          todo
        } else {
          fail
        }
      } else {
        callback(weight, tag_roots)
      }
    }
  }
}

validator rmn {
  withdraw(redeemer: SpendEndpoint, cred: Credential, tx: Transaction) {
    let Transaction { inputs, reference_inputs, .. } = tx

    expect Script(own_cred_hash) = cred

    let own_address = Address(cred, None)

    let value = assets.from_asset(own_cred_hash, "global", 1)

    let voter_value = assets.from_asset(own_cred_hash, "voter", 1)

    let root_value = assets.from_asset(own_cred_hash, "tagged_root", 1)

    expect Some(Input { output: global_state_input, .. }) =
      reference_inputs
        |> list.find(
            fn(input) {
              expect [_, ..rest] = input.output.value |> to_dict |> to_pairs

              dataify(value) == dataify(rest)
            },
          )

    expect InlineDatum(global) = global_state_input.datum

    expect Global {
      owner,
      bless_weight_threshold,
      curse_weight_threshold,
      accumulated_weight,
      version,
      curse_active,
    } = global

    when redeemer is {
      VoteToBless { roots } -> {
        expect False = curse_active

        let valid_votes = 0

        todo
      }
    }
  }

  else(_) {
    fail
  }
}
