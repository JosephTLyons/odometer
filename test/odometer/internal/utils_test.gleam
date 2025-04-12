import gleeunit/should
import odometer/internal/utils

pub fn div_mod_test() {
  let #(quotient, remainder) = utils.div_mod(13, 5)
  should.equal(quotient, 2)
  should.equal(remainder, 3)
}
