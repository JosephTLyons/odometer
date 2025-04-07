import gleam/int
import gleam/list
import gleam/order
import glearray.{type Array}

type Symbols(a) {
  Symbols(symbols: Array(a), indices: List(Int), base: Int)
}

fn new_symbols(symbols symbols: List(a), repeat repeat: Int) -> Symbols(a) {
  Symbols(
    symbols: glearray.from_list(symbols),
    indices: list.repeat(0, repeat),
    base: list.length(symbols),
  )
}

pub opaque type Odometer(a) {
  Odometer(state: List(Symbols(a)), overflow: Int)
}

pub fn new() {
  Odometer(state: [], overflow: 0)
}

pub fn from_lists(symbols: List(List(a))) -> Odometer(a) {
  symbols
  |> list.reverse
  |> list.map(new_symbols(symbols: _, repeat: 1))
  |> Odometer(overflow: 0)
}

// TODO: Prevent append after advance?
pub fn append(
  odometer: Odometer(a),
  symbols: List(a),
  repeat: Int,
) -> Odometer(a) {
  let symbols = new_symbols(symbols:, repeat:)
  [symbols, ..odometer.state] |> Odometer(overflow: 0)
}

pub fn readout(odometer: Odometer(a)) -> List(a) {
  readout_symbol_loop(odometer.state, [])
}

fn readout_symbol_loop(state: List(Symbols(a)), acc: List(a)) -> List(a) {
  case state {
    [] -> acc
    [first, ..rest] -> {
      let Symbols(indices:, symbols:, base: _) = first
      let acc = readout_indices_loop(indices:, symbols:, acc:)
      readout_symbol_loop(rest, acc)
    }
  }
}

// TODO: Rename
fn readout_indices_loop(
  indices indices: List(Int),
  symbols symbols: Array(a),
  acc acc: List(a),
) -> List(a) {
  case indices {
    [] -> acc
    [index, ..indices] -> {
      let assert Ok(symbol) = glearray.get(symbols, index)
      let acc = [symbol, ..acc]
      readout_indices_loop(indices:, symbols:, acc:)
    }
  }
}

pub fn advance(odometer: Odometer(a), by by: Int) -> #(Odometer(a), Int) {
  case int.compare(by, 0) {
    order.Eq -> #(odometer, odometer.overflow)
    order.Gt -> {
      let state = odometer.state
      let #(state, overflow) =
        advance_loop(state:, by:, is_increase: True, acc: [])
      let overflow = odometer.overflow + overflow
      #(Odometer(state:, overflow:), overflow)
    }
    order.Lt -> {
      let state = odometer.state
      let #(state, overflow) =
        advance_loop(
          state:,
          by: int.absolute_value(by),
          is_increase: False,
          acc: [],
        )
      let overflow = odometer.overflow - overflow
      #(Odometer(state:, overflow:), overflow)
    }
  }
}

fn advance_loop(
  state state: List(Symbols(a)),
  by by: Int,
  is_increase is_increase: Bool,
  acc acc: List(Symbols(a)),
) -> #(List(Symbols(a)), Int) {
  case state {
    [] -> {
      #(list.reverse(acc), by)
    }
    [symbols, ..rest] -> {
      let #(indices, carry) =
        advance_indices_loop(
          indices: symbols.indices,
          base: symbols.base,
          by: by,
          is_increase: is_increase,
          acc: [],
        )

      let symbols = Symbols(..symbols, indices: indices)

      case carry {
        0 -> #(list.reverse([symbols, ..acc]) |> list.append(rest), 0)
        _ ->
          advance_loop(state: rest, by: carry, is_increase: is_increase, acc: [
            symbols,
            ..acc
          ])
      }
    }
  }
}

fn advance_indices_loop(
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
        True -> {
          let new_index = index + by
          div_mod(new_index, base)
        }
        False -> {
          let new_index = index - by
          case new_index < 0 {
            True -> {
              let abs_new_index = int.absolute_value(new_index)
              let borrow_count =
                abs_new_index
                / base
                + case abs_new_index % base {
                  0 -> 0
                  _ -> 1
                }
              let remainder = case abs_new_index % base {
                0 -> 0
                r -> base - r
              }
              #(borrow_count, remainder)
            }
            False -> #(0, new_index)
          }
        }
      }

      let acc = [remainder, ..acc]

      case carry {
        0 -> #(list.reverse(acc) |> list.append(indices), 0)
        _ ->
          advance_indices_loop(
            indices:,
            base:,
            by: carry,
            is_increase: is_increase,
            acc:,
          )
      }
    }
  }
}

@internal
pub fn div_mod(dividend: Int, divisor: Int) -> #(Int, Int) {
  let quotient = dividend / divisor
  let remainder = dividend % divisor
  #(quotient, remainder)
}
