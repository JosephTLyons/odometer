import gleam/int
import gleam/list
import glearray.{type Array}
import odometer/internal/utils

pub type RepeatableWheel(a) {
  RepeatableWheel(items: Array(a), indices: List(Int), base: Int)
}

pub fn new(items items: List(a), repeat repeat: Int) -> RepeatableWheel(a) {
  RepeatableWheel(
    items: glearray.from_list(items),
    indices: list.repeat(0, repeat),
    base: list.length(items),
  )
}

pub fn readout(r_wheel: RepeatableWheel(a)) -> List(a) {
  let RepeatableWheel(items:, indices:, base: _) = r_wheel
  readout_loop(indices:, items:, acc: [])
}

fn readout_loop(
  indices indices: List(Int),
  items items: Array(a),
  acc acc: List(a),
) -> List(a) {
  case indices {
    [] -> acc
    [index, ..indices] -> {
      let assert Ok(item) = glearray.get(items, index)
      let acc = [item, ..acc]
      readout_loop(indices:, items:, acc:)
    }
  }
}

pub fn advance(
  r_wheel r_wheel: RepeatableWheel(a),
  by by: Int,
  is_increase is_increase: Bool,
) -> #(RepeatableWheel(a), Int) {
  let RepeatableWheel(items: _, indices:, base:) = r_wheel
  let #(indices, overflow) =
    advance_loop(indices:, base:, by:, is_increase:, acc: [])
  let r_wheel = RepeatableWheel(..r_wheel, indices:)
  #(r_wheel, overflow)
}

fn advance_loop(
  indices indices: List(Int),
  base base: Int,
  by by: Int,
  is_increase is_increase: Bool,
  acc acc: List(Int),
) -> #(List(Int), Int) {
  case indices {
    [] -> #(list.reverse(acc), by)
    [index, ..indices] -> {
      let #(carry, remainder) = case is_increase {
        True -> utils.div_mod(index + by, base)
        False -> {
          let new_index = index - by
          case new_index >= 0 {
            True -> #(0, new_index)
            False -> {
              let abs_new_index = int.absolute_value(new_index)
              let borrow_count = case utils.div_mod(abs_new_index, base) {
                #(q, 0) -> q
                #(q, _) -> q + 1
              }
              let remainder = case abs_new_index % base {
                0 -> 0
                r -> base - r
              }
              #(borrow_count, remainder)
            }
          }
        }
      }

      let acc = [remainder, ..acc]

      case carry {
        0 -> #(list.reverse(acc) |> list.append(indices), 0)
        _ -> advance_loop(indices:, base:, by: carry, is_increase:, acc:)
      }
    }
  }
}
// TODO: Can we move is_increase into the wheel module only?
// TODO: Can list of indices be killed off in favor of storing number of virtual wheels and value of
