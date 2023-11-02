# USB_CDC

This repo implements apb bus wrapper for usb cdc ip in [this repo](https://github.com/ulixxe/usb_cdc)

## I/O Registers
| Register | Offset | Mode         | Size | Description |
| -------- | ------ | ------------ | ------|----- |
| TX Data      | 0x0000  | W        | 8|Write data to TX FIFO   |
| RX Data      | 0x0004  | R        | 8|Read data from RX FIFO  |
| TX FIFO Level      | 0x0008  | R |4       | The TX FIFO data level (number of bytes in the FIFO) |
| RX FIFO Level      | 0x000C  | R |4       | The RX FIFO data level (number of bytes in the FIFO) |
| TX FIFO Level Threshold| 0x0010   | RW| 4|TX FIFO: fire an interrupt if level < threshold |
| RX FIFO Level Threshold| 0x0014   | RW| 4|RX FIFO: fire an interrupt if level > threshold |
| RIS | 0x0018 | R | 4|Raw Status Register |
| MIS | 0x001C | R |  4|Masked Status Register |
| IM | 0x0020 | RW |  4|Interrupts Masking Register; enable and disables interrupts |
| IC | 0x0024 | W |  4|Interrupts Clear Register; write 1 to clear the flag |

## Interrupt flags 
The following applies to registers: RIS, MIS, IM and IC.
|bit|flag|
|---|----|
|0| TX FIFO is Empty |
|1| TX FIFO level is below the value in the TX FIFO Level Threshold Register |
|2| RX FIFO is Full |
|3| RX FIFO level is above the value in the RX FIFO Level Threshold Register |
