#lang racket

; Trabajo Practico Integrador - LogiAR - Grupo L
; Conrado De Napoli - Federico Del Carlo
; Ignacio Larocca - Kevin Larguia


(define despachos-lunes '(
((aa180be 15000) (4500 3000) (9000))
((ab550zd 12000) (3000 5000 1000) (500 2000))
((aa790ga 19000) (3500) (2800) (1100 400))
((bb4824 9000))
))


; funciones auxiliares

; devuelve los datos principales del camion
(define (datos-camion despacho)
  (car despacho) ; Devuelve la lista con la patente y carga maxima
)
; devuelve la patente de un despacho
(define (obtener-patente despacho)
  (car (datos-camion despacho))
)
; devuelve los contenedores de un despacho
(define (obtener-contenedores despacho)
  (cdr despacho)
)
; ---------------------------
; Consigna 1
; ---------------------------
(define (lista-camiones despachos) ; Retorna la lista de patentes
  (if (null? despachos)
      '() ; Caso base: si ya no quedan despachos, devuelve ()
      (cons
       (obtener-patente (car despachos)) ; Patente de un camion
       (lista-camiones (cdr despachos)) ; enlazada con el resto de patentes analizadas
      )
  )
)

; funciones auxs para la consigna 2

; suma los numeros de una lista
(define (sumar lista)
  (if (null? lista)
      0
      (+ (car lista)
         (sumar (cdr lista)))
  )
)
; suma las cargas de todos los contenedores
(define (sumar-contenedores contenedores)
  (if (null? contenedores)
      0
      (+ (sumar (car contenedores))
         (sumar-contenedores (cdr contenedores)))
  )
)
; calcula la carga total de un despacho
(define (carga-total despacho)
  (sumar-contenedores
   (obtener-contenedores despacho))
)

;--------------------------
; Consigna 2
;--------------------------

(define (carga-kg despachos patente)
  (if (null? despachos)
      "Patente inexistente"
      (if (equal? (obtener-patente (car despachos)) patente)
          (carga-total (car despachos)) ; Si la patente coincide, devuelve los kilos de ese camion
          (carga-kg (cdr despachos) patente)
      )
  )
)

; ejemplos:
(lista-camiones despachos-lunes)
; -> '(aa180be ab550zd aa790ga)

; (carga-kg despachos-lunes 'aa790ga)
; -> 7800

; (carga-kg despachos-lunes 'ad802fh)
; -> "Patente inexistente"