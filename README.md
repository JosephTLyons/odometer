# odometer

[![Package Version](https://img.shields.io/hexpm/v/odometer)](https://hex.pm/packages/odometer)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/odometer/)

Cycle through item combinations.

## Installation

```sh
gleam add odometer
```

## Usage

```gleam
import odometer

pub fn main() {
  let od = odometer.new() |> odometer.append(["🌑", "🌕"], 2) |> odometer.append(["🌞", "⛅"], 2)
  odometer.readout(od)
  // ["🌑", "🌑", "🌞", "🌞"]

  let #(od, overflow) = odometer.advance(od, 10)
  odometer.readout(od)
  // ["🌕", "🌑", "⛅", "🌞"]
  overflow
  // 0
}
```
