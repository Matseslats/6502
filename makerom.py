# definer instruksene som skal kjøres
code = bytearray([
    # sett alle pinnene til utganger
    0xa9, 0xff,             # lda $ff
    0x8D, 0x02, 0x60,       # sta $6002

    0xa9, 0x55,             # lda $55     <----------
    0x8D, 0x00, 0x60,       # sta $6000              |
                                                #    |
    0xa9, 0xaa,             # lda $aa                |
    0x8D, 0x00, 0x60,       # sta $6000              |
                                                #    |
    0x4c, 0x05, 0x80        # jmp $8005    hopp til --
])

# lag en array med heksedesimale tall som inneholder instrukser,
# alle plasse som ikke er tatt fylles med "ea", noop
rom = code + bytearray([0xea] * (32768 - len(code)))

# data i adresse fffc settes til 00
# 7ffc ser ut som fffc for mikroprosessoren.
rom[0x7ffc] = 0x00
rom[0x7ffd] = 0x80
# leses som 8000, men mikroprosessoren ser adresse 0000

# lag en ny fil, wb = write binary
with open("rom.bin", "wb") as out_file:
    # skriv rom arrayen i out_file
    out_file.write(rom)
