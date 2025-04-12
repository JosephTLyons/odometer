import gleam/int
import gleam/list
import gleam/order
import odometer/internal/repeatable_wheel.{type RepeatableWheel, RepeatableWheel}

// TODO: Doc comments

pub opaque type Odometer(a) {
  Odometer(state: List(RepeatableWheel(a)), overflow: Int)
}

pub fn new() {
  Odometer(state: [], overflow: 0)
}

pub fn from_lists(items: List(List(a))) -> Odometer(a) {
  items
  |> list.reverse
  |> list.map(repeatable_wheel.new(items: _, repeat: 1))
  |> Odometer(overflow: 0)
}

// TODO: Prevent append after advance?
// TODO: What should happen to overflow after appending?
pub fn append(odometer: Odometer(a), items: List(a), repeat: Int) -> Odometer(a) {
  let r_wheel = repeatable_wheel.new(items:, repeat:)
  [r_wheel, ..odometer.state] |> Odometer(overflow: 0)
}

pub fn readout(odometer: Odometer(a)) -> List(a) {
  readout_loop(odometer.state, []) |> list.flatten
}

fn readout_loop(
  state: List(RepeatableWheel(a)),
  acc: List(List(a)),
) -> List(List(a)) {
  case state {
    [] -> acc
    [r_wheel, ..r_wheels] -> {
      let items = repeatable_wheel.readout(r_wheel)
      readout_loop(r_wheels, [items, ..acc])
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
  state state: List(RepeatableWheel(a)),
  by by: Int,
  is_increase is_increase: Bool,
  acc acc: List(RepeatableWheel(a)),
) -> #(List(RepeatableWheel(a)), Int) {
  case state {
    [] -> {
      #(list.reverse(acc), by)
    }
    [r_wheel, ..wheels] -> {
      let #(r_wheel, overflow) =
        repeatable_wheel.advance(r_wheel:, by:, is_increase:)

      case overflow {
        0 -> #(list.reverse([r_wheel, ..acc]) |> list.append(wheels), 0)
        _ ->
          advance_loop(state: wheels, by: overflow, is_increase:, acc: [
            r_wheel,
            ..acc
          ])
      }
    }
  }
}
// Unify public function labelled arguments - have them or not?
