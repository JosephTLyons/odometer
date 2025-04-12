pub fn div_mod(dividend: Int, divisor: Int) -> #(Int, Int) {
  let quotient = dividend / divisor
  let remainder = dividend % divisor
  #(quotient, remainder)
}
