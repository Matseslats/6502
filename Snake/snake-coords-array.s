PORTB = $6000 ; I/O PORT B på VIA
PORTA = $6001 ; I/O PORT A på VIA
DDRB = $6002 ; Data retning PORT B på VIA
DDRA = $6003 ; Data retning PORT A på VIA
PCR = $600c ; Write Handshake Control, s.12 i datablad
IFR = $600d ; Interrupt flag register, s.26
IER = $600e ; Input enable register, s.27

vidpage = $0000 ; 2 bytes, adresse som lagrer hvor video minne starter
bakgrunn_farge = $0002 ; 1 byte, adressen til fargen til bakgrunnen
skriv_piksel = $0003 ; 2 bytes, et sted å lagre pikselen som skal skrives
temp_x = $0005 ; 1 byte, brukes når piksel skrives til VRAM, og jeg ikke vil miste x verdi
temp_y = $0006 ; 1 byte
debug_farge = $0007 ; 1 byte

snake_farge = $0010 ; 1 byte, adressen til fargen til slangen
array_offsett = $0011 ; 2 bytes, hvor lenge etter start x og y skal posisjonen hentes fra?
snake_lengde = $0013 ; 2 bytes, hvor lang er slangen?
temp_offsett = $0015 ; 2 bytes, brukes for å hente adressene til slange pos

snake_x_start = $0200 ; x bytes, adresse start til x posisjon til slangen
snake_y_start = $20FF ; x bytes, adresse start til y posisjon til slangen

  .org $8000 ; ROM starter på denne adressen
	
  ; Initialiser program
reset:
  ; Initialiser vidpage som startadresse til video RAM, $2000
  lda #$20
  sta vidpage + 1
  lda #$00
  sta vidpage
  
  lda #%11111111 ; Farge på slangen
  sta snake_farge

  lda #0;#%101010 ; Farge på bakgrunnen, --GGBBRR, 10101010
  sta bakgrunn_farge
  
  lda #%00110011
  sta debug_farge
  
  lda #5 ; Slangen er så lang, desimal
  sta snake_lengde
  
  lda #15
  sta $007F
  sta $083F
  
  lda #19
  sta $0080
  sta $0840
  
  lda #20
  sta $0081
  sta $0841
  
  lda #21
  sta $0082
  sta $0842
  
  lda #22
  sta $0083
  sta $0843
  
  lda #27
  sta $0084
  sta $0844
  
  lda #0
  sta array_offsett
  
  ; Initialiser temp offsett til å være 0
  lda #0
  sta temp_offsett
  
  
; ------------------------ Bakgrunn ------------------------
; Fyll skjermen med bakgrunnsfargen start på 64, 0, og jobb x nedover og y oppover. Fyll hver piksel med bakgrunnsfargen
  ldx #31 ; Start på x verdi 64 (40 hex)
  ldy #0  ; Start på y verdi 0 
  lda bakgrunn_farge
  
; Lagre fargen til alle pikslene.
fyll_bakgrunnen:
  sta (vidpage), y ; Skriv fargen til startadresse + y verdi. Parantes betyr at det er et 16 bit nummer og at adressen henter der og en byte høyere
  
  iny ; Gjør y en større
  bne fyll_bakgrunnen ; Hvis den har hatt rollover, gått over 255, gå til fyll
  
  inc vidpage + 1 ; Gå til neste rad
  dex ; Gjør x en mindre
  bne fyll_bakgrunnen ; Hvis den ikke har kommet til 0, gå til fyll
; ------------------------ Bakgrunn ------------------------





loop:
; Tegn slange
  jsr draw_snake
  inc array_offsett
  
  ldy #$CC
longer_delay:
  ldx #$FF
delay:
  dex
  bne delay
  
  dey
  bne longer_delay
  
  jmp loop
  
draw_snake:
  ; ---- Lag riktig adresse X ----
  clc
  lda snake_lengde ; Start å vise fra høyest byte
  sbc temp_offsett ; Brukes for å loope gjennom alle posisjonene
  clc
  adc array_offsett ; Legg til verdien som viser hvor lenge etter start slangen skal vises fra
  ; Sjekk at verdien er innenfor riktig område
  tax
  lda snake_x_start, x ; Hest verdien i adressen det x verdien er lagret
  sta temp_x ; Legre for å vises på skjermen
  
  ; ---- Lag riktig adresse Y ----
  clc
  lda snake_lengde ; Start å vise fra høyest byte
  sbc temp_offsett ; Brukes for å loope gjennom alle posisjonene
  clc
  adc array_offsett ; Legg til verdien som viser hvor lenge etter start slangen skal vises fra
  tax
  lda snake_y_start, x ; Hest verdien i adressen det x verdien er lagret
  sta temp_y ; Lagre for å vises på skjermen
  
  ; Skriv piksel riktig farge 
  lda snake_farge
  jsr skriv_posisjon ; (mister a, x, y)
  
  ; Gjør deg klar til å skrive neste slangebit
  inc temp_offsett
  lda temp_offsett
  cmp snake_lengde
  bne draw_snake ; Hvis offsett IKKE har gått gjennom alle verdiene, vis neste slangebit
  
  ; Hvis alle verdiene er gått gjennom, 
  ; 	resett temp_offsett for å gjøre klar til neste gang
  ; 	Tegn bakgrunn over forrige piksel
  ; 	Legg til en i array_offsett (Må legge inn sjekk for å rullere i gitt ommråde
  lda bakgrunn_farge
  jsr skriv_posisjon ; (mister a, x, y)
  
  lda #0
  sta temp_offsett
  
  rts


skriv_posisjon:  
  tax
; Gjør omm x og y verdi, til pos, og skriv piksel som slangefargen.
  ; Tøm pikselverdien
  lda #$0
  sta skriv_piksel
  lda #%00100000
  sta skriv_piksel + 1
  ; Legg til snake sin y verdi i byten til venstre
  lda temp_y ; Last inn y verdien i accumulator
  clc
  ror ; Flytt bitene en til høyre
  and #%00011111 ; Bare ta vare på de fem minste bitene
  ora skriv_piksel + 1 ; Legg til startpos
  sta skriv_piksel + 1 ; Lagre byte
  ; Legg til snake sin y verdi i vyten til høyre
  lda temp_y ; Last inn y verdien i accumulator
  clc
  ror ; y bit 0 går inn i carry
  ror ; y bit 0 går til bit 7 posisjonen
  and #%10000000 ; Bare ta vare på det som var bit y0
  ora skriv_piksel
  sta skriv_piksel
  ; Legg til snake sin x verdi i pikselverdien
  clc
  lda temp_x ; Last inn x verdien i accumulator
  and #%01111111 ; Ikke ta vare på verdien der y er
  ora skriv_piksel
  sta skriv_piksel
  
  txa
  ldy #$0
  sta (skriv_piksel), y ; En to byte variabel.
  
  ; Returner til loop
  rts ; JSR BRUKER TO STACK NUMMERE!!!!!
	

; Reset/IRQ/NMI vektorer
  .org $fffa
  .word reset
  .word reset
  .word reset