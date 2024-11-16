# BootSector Snake Game in x86 assembly

---

https://github.com/user-attachments/assets/341268ff-ab73-44f5-a5b7-cc0a26cd2d29

---

<img width="1440" alt="test" src="https://github.com/user-attachments/assets/7b835d50-ce78-4ad7-a7f3-bccd39f53ac5">


---
#### Requirements......

QEMU - An emulator to test our bootloader would eliminate the risk of inadvertently damaging our hardware due to poorly written OS code.

```
sudo apt install qemu-system-x86
```
---

##### FASM

```
sudo apt-get install fasm
```

---

### To start the game....

```bash
lynk@Linux ~/x/snake> fasm snake.asm
flat assembler  version 1.73.30  (16384 kilobytes memory)
3 passes, 512 bytes.
lynk@Linux ~/x/snake> qemu-system-i386 -fda snake.bin
```
---


