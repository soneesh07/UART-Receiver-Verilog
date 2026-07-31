# UART Receiver in Verilog HDL

An 8-bit UART (Universal Asynchronous Receiver Transmitter) Receiver implemented in Verilog HDL using a modular RTL architecture. The design receives serial data (LSB first), reconstructs the original 8-bit parallel data, and indicates successful reception using a `done` signal.

---

## Features

- 8-bit UART Receiver
- Finite State Machine (FSM) based control
- Configurable baud rate generator
- Bit counter for tracking received bits
- Shift register for serial-to-parallel conversion
- Busy and Done status signals
- Modular RTL design
- Verified using Icarus Verilog and GTKWave

---

## Design Architecture

The receiver consists of the following modules:

- **UART Receiver (Top Module)**
  - Controls the receive operation using an FSM.

- **Baud Counter**
  - Generates the baud timing pulse.

- **Bit Counter**
  - Counts the number of received data bits.

- **Shift Register**
  - Receives serial bits (LSB first) and converts them into an 8-bit parallel word.

---

## FSM States

| State | Description |
|--------|-------------|
| IDLE | Waits for the start bit (`rx = 0`) |
| START | Waits one baud period after detecting the start bit |
| DATA | Receives 8 serial data bits |
| STOP | Waits for the stop bit and completes reception |

---
## UART Receiver Block Diagram

```text
                 +----------------+
RX ------------->| Start Detector |
                 +----------------+
                         |
                         v
                 +----------------+
                 |      FSM       |
                 +----------------+
                    |         |
                    |         |
                    v         v
           +---------------+  +--------------+
           | Baud Counter  |  | Bit Counter  |
           +---------------+  +--------------+
                    |                |
                    +-------+--------+
                            |
                            v
                     +---------------+
                     | Shift Register|
                     +---------------+
                            |
                            v
                     +---------------+
                     |   data_out    |
                     +---------------+
```
## Simulation

Simulation performed using:

- Icarus Verilog
- GTKWave

### Compile

```bash
iverilog -o uart_rx_sim uart_rx.v uart_rx_tb.v
```

### Run

```bash
vvp uart_rx_sim
```

### View Waveform

```bash
gtkwave uart_rx.vcd
```

---

## Test Case

Input Byte (LSB First)

```
10110010
```

Simulation Output

```
Received Data = 10110010
TEST PASSED
```

---

## Project Structure

```
UART-Receiver-Verilog/
│
├── uart_rx.v          # UART Receiver RTL
├── uart_rx_tb.v       # Testbench
├── README.md
└── .gitignore
```

---

## Future Improvements

- Mid-bit sampling for improved timing accuracy
- Framing error detection
- Parity bit support
- Configurable data width
- Oversampling (8× / 16×)

---

## Author

**Soneesh Dega**

Electrical Engineering Undergraduate  
Indian Institute of Technology Kharagpur
