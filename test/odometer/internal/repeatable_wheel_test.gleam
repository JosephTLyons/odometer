import gleeunit/should
import odometer/internal/repeatable_wheel.{type RepeatableWheel}

pub fn repeatable_wheel_test() {
  let r_wheel = repeatable_wheel.new([1, 2], 2)
  let by = 1
  let is_increase = True
  let readout = repeatable_wheel.readout(r_wheel)
  should.equal(readout, [1, 1])
  let r_wheel = advance_and_assert(r_wheel, by, is_increase, [1, 2], 0)
  let r_wheel = advance_and_assert(r_wheel, by, is_increase, [2, 1], 0)
  let r_wheel = advance_and_assert(r_wheel, by, is_increase, [2, 2], 0)
  advance_and_assert(r_wheel, by, is_increase, [1, 1], 1)
}

fn advance_and_assert(
  r_wheel: RepeatableWheel(a),
  by by: Int,
  is_increase is_increase: Bool,
  readout_state readout_state: List(a),
  overflow overflow_state: Int,
) -> RepeatableWheel(a) {
  let #(r_wheel, overflow) =
    repeatable_wheel.advance(r_wheel:, by:, is_increase:)
  let readout = repeatable_wheel.readout(r_wheel)
  should.equal(readout, readout_state)
  should.equal(overflow, overflow_state)
  r_wheel
}
