vidpage = $0000 ; 2 bytes
;start_color = $0002 ; 1 byte
  .org $8000 ; ROM starter på denne adressen
  
reset:
  ; Initialiser startfargen til 1
;  lda #$0
;  sta start_color 

loop:
  ; Initialiser vidpage som startadresse til video RAM $2000
  lda #$20
  sta vidpage + 1
  lda #$00
  sta vidpage
  
  ldx #$20 ; X teller ned hvor mange sider video ram skal gå
  ldy #$0 ; Fyll en side, starter med 0
;  inc start_color ; start med en ny farge
  lda #$0;start_color ; fargen til pikselen
  
page:
  sta (vidpage), y ; Skriv A registeret til adresse vidpage + y
  
;  and #$7f ; Hvis vi har gått gjennom 127 farger
;  bne inc_color
;  clc
;  adc #$1 ; legg til 1, igjen
  
;inc_color:
  clc
  adc #$1 ; Hvis ikke, Legg til 1 i farge verdien
  
  iny ; Gå til neste piksel
  bne page ; Hvis den ikke hadde on rollover, gå til page
  
  inc vidpage + 1 ; Gå til neste side
  dex ; Trekk fra 1 fra x
  bne page ; Hvis x ikke hadde rollover, gå til page (Gjør det 20 ganger)
  
  jmp loop
  
  
; Reset/IRQ/NMI vektorer
  .org $fffa
  .word reset
  .word reset
  .word reset