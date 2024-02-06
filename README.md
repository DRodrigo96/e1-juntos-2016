# Juntos 2016

---

## Descripción
Un ejercicio demostrativo de evaluación de impacto de un programa social.
Tomo el programa Juntos y busco replicar un experimento aleatorio con la información de la encuesta a nivel de hogares ENAHO (Encuesta Nacional de Hogares). Uso Stata para realizar el ejercicio.

---

## Datos
Toda la información es pública: las bases de datos se pueden encontrar en http://iinei.inei.gob.pe/microdatos/. Son necesarias las bases:
* `enaho01a-2015-300.dta`: microdatos de INEI, base anual 2015, código de módulo: 3.
* `enaho01a-2016-300.dta`: microdatos de INEI, base anual 2016, código de módulo: 3.
* `enaho01-2016-700.dta`: microdatos de INEI, base anual 2016, código de módulo: 37.
* `sumaria-2016.dta`: microdatos de INEI, base anual 2016, código de módulo: 34.
* `r_numbers.dta`: números aleatorios para replicación del ejercicio.

---

## Folders
1) `data`: descomprimir el folder ZIP que contiene las  bases de datos necesarias para el ejercicio.
2) `scripts`: En el archivo `./scripts/main.do`, cambiar la variable `cwd` según corresponda y ejecutar.

---
