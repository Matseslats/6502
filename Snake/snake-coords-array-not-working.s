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
temp_snake_lengde = $0007 ; 1 byte

snake_farge = $0010 ; 1 byte, adressen til fargen til slangen
snake_peker = $0011 ; 2 bytes, hvor i ram slangemns pos skal leses fra, samme på x og y
snake_lengde = $0013 ; 2 bytes, hvor lang er slangen?

snake_x_start = $0080 ; 1 byte, adresse start til x posisjon til slangen
snake_y_start = $0840 ; 1 byte, adresse start til y posisjon til slangen

  .org $8000 ; ROM starter på denne adressen
	
  ; Initialiser program
reset:
  ; Initialiser vidpage som startadresse til video RAM, $2000
  lda #$20
  sta vidpage + 1
  lda #$00
  sta vidpage
  
  lda #%11111111 ; Farge på slangen 00000100, AA?
  sta snake_farge

  lda #0;#%101010 ; Farge på bakgrunnen, --GGBBRR, 10101010
  sta bakgrunn_farge
  
  lda #5 ; Slangen er så lang, desimal
  sta snake_lengde
  
  lda #0
  sta snake_peker
  sta snake_x_start
  sta snake_y_start
  
  ; Initialiser to av rutene i slangen.
  lda snake_lengde
  adc snake_peker
  tay
  lda #22
  sta snake_x_start, y
  lda #22
  sta snake_y_start, y
  tya
  ; Denne verdien bestemmer blink
  sbc #1
  tay
  lda #11
  sta snake_x_start, y
  lda #11
  sta snake_y_start, y
  
  
  
; Fyll skjermen med bakgrunnsfargen start på 64, 0, og jobb x nedover og y oppover. Fyll hver piksel med bakgrunnsfargen
  ldx #$40 ; Start på x verdi 64 (40 hex)
  ldy #$0 ; Start på y verdi 0 
  lda bakgrunn_farge
  
; Lagre fargen til alle pikslene.
fyll_bakgrunnen:
  sta (vidpage), y ; Skriv fargen til startadresse + y verdi. Parantes betyr at det er et 16 bit nummer.
  
  iny ; Gjør y en større
  bne fyll_bakgrunnen ; Hvis den har hatt rollover, gått over 255, gå til fyll
  
  inc vidpage + 1 ; Gå til neste rad
  dex ; Gjør x en mindre
  bne fyll_bakgrunnen ; Hvis den ikke har kommet til 0, gå til fyll
  
loop:
  ; Mål: Les verdien i adresse (snake_x_start+snake_peker+snake_lengde)
  lda snake_lengde
  sta temp_snake_lengde
slange_posisjoner:
  lda temp_snake_lengde
  adc snake_peker ; Legg til peker i lengde for å se hvor data skal leses fra
  ; Flytt offsett til y for å bruke "Absolute Indexed with Y: a,y"
  tay
  ; Last inn a med verdien av adresse(adresse(slangen)+data(offsett))
  lda snake_x_start, y
  ; Push resultatet til midlertidig variabel
  sta temp_x
  lda snake_y_start, y
  sta temp_y ; Y verdien lagres i y variabel
  
  ; Vis pikselen på skjermen
  lda snake_farge
  pha
  jsr skriv_posisjon ; (1x pla, mister x)
  
  lda temp_snake_lengde
  dec temp_snake_lengde
  bmi slange_posisjoner ; Hvis resultatet er minus, farg bakgrunnspiksel, hvis ikke, gå til neste posisjon.
  
  lda bakgrunn_farge
  pha ; farge på piksel -> stack
  jsr skriv_posisjon ; (1x pla, mister x)
  
  jmp loop


skriv_posisjon:  
; Gjør omm x og y verdi, til pos, og skriv piksel som slangefargen.
  ; Tøm pikselverdien
  lda #$0
  sta skriv_piksel
  lda #$20
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
  
  pla ; Hent fargen på piksel fra stack
  ldx #$0
  sta (skriv_piksel, x) ; En to byte variabel.
  
  ; Returner til loop
  rts
	

; Reset/IRQ/NMI vektorer
  .org $fffa
  .word reset
  .word reset
  .word reset