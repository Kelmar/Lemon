
# Lemon
A (not so) basic monitor program for my 6502 build.

## TODO
- [x] Buffered UART with 16C550C
- [ ] Line editor
- [ ] Command processing
- [ ] View/Modify Memory
- [ ] X/Y modem uploads
- [ ] Binary execution
- [ ] Disassembler?
- [ ] Generic driver model?
  So people can use something other than the 16C550C

## Zero page mapping
| ZP | Description                      |
| -- | -------------------------------- |
| 00 | Reserved for banking             |
| 01 | Reserved for banking             |
| 02 | Kernel 8-bit parameter/register  |
| 03 | Kernel 8-bit parameter/register  |
| 04 | Kernel 8-bit parameter/register  |
| 05 | Kernel 8-bit parameter/register  |
| 06 | Kernel 16-bit parameter/register |
| 08 | Kernel 16-bit parameter/register |
| 0A | Kernel 16-bit paraemter/register |
| 0C | Kernel 16-bit parameter/register |
| 0E | Kernel 32-bit parameter/register |
| 12 | Kernel 32-bit parameter/register |
