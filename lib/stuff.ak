use aiken/builtin

fn hash_item(hash_count: Int) -> fn(ByteArray) -> ByteArray {
  if hash_count == 0 {
    identity
  } else {
    let func = hash_item(hash_count - 1)

    fn(list) {
      list
        |> builtin.blake2b_224
        |> func
    }
  }
}

const hash_2000 = hash_item(2000)

test thing() {
  let x = Some(100) |> builtin.serialise_data

  hash_2000(x) == #""
}
