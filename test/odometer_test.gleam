import gleam/int
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should
import odometer.{type Odometer}

pub fn main() {
  gleeunit.main()
}

pub fn readme_example_test() {
  let od =
    odometer.new()
    |> odometer.append(["🌑", "🌕"], 2)
    |> odometer.append(["🌞", "⛅"], 2)
  let readout = odometer.readout(od)
  should.equal(readout, ["🌑", "🌑", "🌞", "🌞"])
  let #(od, overflow) = odometer.advance(od, 10)
  let readout = odometer.readout(od)
  should.equal(readout, ["🌕", "🌑", "⛅", "🌞"])
  should.equal(overflow, 0)
}

pub fn advance_by_negative_1_test() {
  let od =
    odometer.new()
    |> odometer.append(["a", "b", "c"], 1)
    |> odometer.append(["d", "e"], 1)

  let readout = odometer.readout(od)
  should.equal(readout, ["a", "d"])

  let by = -1
  let od = advance_and_assert(od, by, ["c", "e"], -1)
  let od = advance_and_assert(od, by, ["c", "d"], -1)
  let od = advance_and_assert(od, by, ["b", "e"], -1)
  let od = advance_and_assert(od, by, ["b", "d"], -1)
  let od = advance_and_assert(od, by, ["a", "e"], -1)
  advance_and_assert(od, by, ["a", "d"], -1)
}

pub fn advance_by_0_test() {
  let od = odometer.new() |> odometer.append(["a", "b", "c"], 2)

  let readout = odometer.readout(od)
  should.equal(readout, ["a", "a"])

  let by = 0
  let od = advance_and_assert(od, by, ["a", "a"], 0)
  let od = advance_and_assert(od, by, ["a", "a"], 0)
  advance_and_assert(od, by, ["a", "a"], 0)
}

pub fn advance_by_1_test() {
  let od =
    odometer.new()
    |> odometer.append(["a", "b", "c"], 1)
    |> odometer.append(["d", "e"], 1)

  let readout = odometer.readout(od)
  should.equal(readout, ["a", "d"])

  let by = 1
  let od = advance_and_assert(od, by, ["a", "e"], 0)
  let od = advance_and_assert(od, by, ["b", "d"], 0)
  let od = advance_and_assert(od, by, ["b", "e"], 0)
  let od = advance_and_assert(od, by, ["c", "d"], 0)
  let od = advance_and_assert(od, by, ["c", "e"], 0)
  advance_and_assert(od, by, ["a", "d"], 1)
}

pub fn from_lists_test() {
  let od = odometer.from_lists([["a", "b", "c"], ["x", "y", "z"]])

  let readout = odometer.readout(od)
  should.equal(readout, ["a", "x"])

  let by = 1
  let od = advance_and_assert(od, by, ["a", "y"], 0)
  let od = advance_and_assert(od, by, ["a", "z"], 0)
  advance_and_assert(od, by, ["b", "x"], 0)
}

pub fn advance_by_2_test() {
  let od = odometer.new() |> odometer.append(["a", "b", "c"], 2)
  let readout = odometer.readout(od)
  should.equal(readout, ["a", "a"])

  let by = 2
  let od = advance_and_assert(od, by, ["a", "c"], 0)
  let od = advance_and_assert(od, by, ["b", "b"], 0)
  let od = advance_and_assert(od, by, ["c", "a"], 0)
  let od = advance_and_assert(od, by, ["c", "c"], 0)
  advance_and_assert(od, by, ["a", "b"], 1)
}

pub fn multiple_overflow_test() {
  let od = odometer.new() |> odometer.append(["a", "b"], 1)
  let readout = odometer.readout(od)
  should.equal(readout, ["a"])

  let by = 1
  let od = advance_and_assert(od, by, ["b"], 0)
  let od = advance_and_assert(od, by, ["a"], 1)
  let od = advance_and_assert(od, by, ["b"], 1)
  let od = advance_and_assert(od, by, ["a"], 2)

  let by = -1
  let od = advance_and_assert(od, by, ["b"], 1)
  let od = advance_and_assert(od, by, ["a"], 1)
  let od = advance_and_assert(od, by, ["b"], 0)
  let od = advance_and_assert(od, by, ["a"], 0)
  let od = advance_and_assert(od, by, ["b"], -1)
  let od = advance_and_assert(od, by, ["a"], -1)
  let od = advance_and_assert(od, by, ["b"], -2)

  let by = 10
  advance_and_assert(od, by, ["b"], 3)
}

pub fn number_test() {
  let value = "123_456_789_000"
  let groups = string.split(value, "_")
  let number_of_groups = list.length(groups)

  let number = string.replace(value, "_", "")
  let assert Ok(number) = int.parse(number)

  let #(od, overflow) =
    odometer.new()
    |> odometer.append(list.range(0, 999), number_of_groups)
    |> odometer.advance(number)

  let assert Ok(expected_output) = list.try_map(groups, int.parse)
  let readout = odometer.readout(od)

  should.equal(readout, expected_output)
  should.equal(overflow, 0)
}

// Can be made generic if is_increase can be pulled into r_wheel module entirely
// From there, we can store it in some sort of test_helpers file
fn advance_and_assert(
  odometer: Odometer(a),
  by by: Int,
  readout_state readout_state: List(a),
  overflow overflow_state: Int,
) -> Odometer(a) {
  let #(odometer, overflow) = odometer.advance(odometer, by:)
  let readout = odometer.readout(odometer)
  should.equal(readout, readout_state)
  should.equal(overflow, overflow_state)
  odometer
}
