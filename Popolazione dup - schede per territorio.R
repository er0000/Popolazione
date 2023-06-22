source(file = "./../../funzioni.R")
library(tidyverse)
library(readr)
library(readxl)
#1. Popolazione schede per territori - dup ----



## 1.a movimento.csv -----
# fonte bilancio: tengo l'anno indicato in timeobs

movimento <- read_delim("F:/DIREZIONE-GENERALE/DATA/Atlante/Schede per territorio_dati/movimento.csv", 
                        delim = ";", escape_double = FALSE, trim_ws = TRUE) %>% colnames()
movimento<-movimento[-c(1,27)]


import_all_datistat(path="F:\\DIREZIONE-GENERALE\\DATA\\DB_SDMX",pattern="DCIS_POPO.*BIL.*A.*",lastYear=T)
import_all_datistat(path="F:\\DIREZIONE-GENERALE\\DATA\\DB_SDMX",pattern="DCIS_POP.*STRBIL.*A.*",lastYear=T)

mov<-`DCIS_POPORESBIL1__Popolazione residente  - bilancio__2022_Com_A.csv` %>% select(-TIPO_INDDEM) %>% 
  filter(!is.na(obsValue)) %>% 
  pivot_wider(names_from = TIPO_INDDEM_label.it, values_from = obsValue) %>% 
  filter(SESSO %in% c(1,2)) %>% 
  select(Anno=obsTime,CodiceComune=ITTER107,	DescrizioneComune=ITTER107_label.it,Sesso=SESSO,
         pop0101=`popolazione inizio periodo`,	pop1231=`popolazione al 31 dicembre`,	Cancellati_altro=`cancellati  in anagrafe per altri motivi`,
         Cancellati_ex=`cancellati  in anagrafe per l'estero`,	Cancellati_int=`cancellati  in anagrafe  per altri comuni`,
         Iscritti_altro=`iscritti  in anagrafe per altri motivi`,	
         Iscritti_ex=`iscritti  in anagrafe dall'estero`,	Iscritti_int=`iscritti  in anagrafe da altri comuni`,
         Morti=morti,	Nati=`nati vivi`,
         Saldo_migratorio=`saldo migratorio anagrafico e per altri motivi`,
         Saldo_censuario=`saldo censuario totale` ,Saldo_naturale=`saldo naturale anagrafico`) %>% 
  mutate(Cancellati=Cancellati_altro+Cancellati_ex+Cancellati_int,
         Iscritti=Iscritti_altro,Iscritti_ex,Iscritti_int,
         CM="Citt. metropolitana di Bologna",
         Anno=Anno+1,
         `Anno movimento`=Anno) %>% 
 
   inner_join(read_excel("F:/DIREZIONE-GENERALE/DATA/DB/Territorio/territorio.xlsx") %>% 
                mutate(CodiceComune=paste0(0,as.character(CodiceComune)))) %>% 
  select(any_of(movimento))

## 1.b popstra struttura.csv -----
# fonte pop residente al primo gennaio: prendo l'anno successivo rispetto al movimento e tiro indietro
# es_ 1° gennaio 2023 = 2022
popstra_struttura <- read_delim("F:/DIREZIONE-GENERALE/DATA/Atlante/Schede per territorio_dati/popstra struttura.csv", 
                                delim = ";", escape_double = FALSE, trim_ws = TRUE)

## 1.c. popstra(base).csv ------


popstra_base_ <- read_delim("F:/DIREZIONE-GENERALE/DATA/Atlante/Schede per territorio_dati/popstra(base).csv", 
                            delim = ";", escape_double = FALSE, trim_ws = TRUE)
