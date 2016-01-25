/************************FUN€åES COM TEXTO****************************************************/
/*******fun‡Æo para retornar um texto partindo de uma string*****************/
FUNCTION fimtexto RETURNS char (INPUT ch-1 AS char, INPUT inicio AS char):
    IF INDEX(ch-1, inicio) = 0 THEN RETURN "".
    IF (LENGTH(ch-1) - INDEX(ch-1, inicio) - LENGTH(inicio) > 0) THEN
        RETURN Substring(ch-1, INDEX(ch-1, inicio) + LENGTH(inicio), LENGTH(ch-1) - INDEX(ch-1, inicio) + 1).
    RETURN ?.
END FUNCTION.

/*******fun‡Æo para retornar um texto antes de uma string*****************/
FUNCTION initexto RETURNS char (INPUT ch-1 AS char, INPUT inicio AS char):
    IF INDEX(ch-1, inicio) = 0 THEN RETURN ch-1.
    RETURN Substring(ch-1, 1, INDEX(ch-1, inicio) - 1).
END FUNCTION.

FUNCTION subtexto RETURNS char (INPUT ch-1 AS char, INPUT inicio AS char, INPUT fim AS CHAR):
    RETURN initexto(fimtexto(ch-1, inicio), fim).
END FUNCTION.

/*********fun‡Æo para remover enters e espa‡os em branco***********/
FUNCTION limpa-texto RETURNS CHAR (INPUT parm1 AS CHAR).
    DEFINE VAR afalbeto AS CHAR NO-UNDO.
    DEFINE VAR letrasDe AS CHAR NO-UNDO.
    DEFINE VAR letrasPara AS CHAR NO-UNDO.

    afalbeto = "ABCDEFGHIJKLMNNOPQRSTUVWXYZ1234567890".
    letrasDe = "µ¶Ç·ÒÖàåéš€ ‚¡¢£ƒÆ…ˆä£‡".
    letrasPara = "AAAAEEIOOUUCaeiouaaaeouuc".

    DEF VAR pos AS INT NO-UNDO.
    DEF VAR j AS INT NO-UNDO.
    DEF VAR retorno AS CHAR NO-UNDO.
    DEF VAR aux AS CHAR NO-UNDO.
    DEF VAR aux2 AS CHAR NO-UNDO.
    DEFINE VARIABLE iasc AS INTEGER   NO-UNDO.

    DO pos = 1 TO LENGTH(parm1):
        aux = SUBSTRING(parm1,pos,1).
        IF aux = " " THEN DO:
            retorno = retorno + " ".
            NEXT.
        END.
        IF INDEX(afalbeto,aux) > 0 THEN DO:
            retorno = retorno + aux.
            NEXT.
        END.
        DO j=1 TO LENGTH(letrasDe):
            aux2 = SUBSTRING(letrasDe, j, 1).
            IF ASC(aux) = ASC(aux2) THEN DO:
                retorno = retorno + SUBSTRING(letrasPara, j, 1).
                NEXT.
            END.
        END.
    END.

    DO pos = 1 TO LENGTH(retorno):
        ASSIGN iasc = ASC(SUBSTRING(retorno, pos, 1)).
        IF (iasc > 64  AND
            iasc < 123) OR
           (iasc > 47 AND
            iasc < 58) OR
            iasc = 32 
            THEN NEXT.
            retorno = REPLACE(retorno, CHR(iasc), "_").
    END.
    retorno = replace(retorno, "_", "").

    DO WHILE index(retorno, "  ") > 0:
        retorno = replace(retorno, "  ", " ").
    END.
    RETURN retorno.
END FUNCTION. 


/*********fun‡Æo para primeira letra ficar em maiuscula***********/
FUNCTION UperInicio RETURNS char (INPUT texto AS char):
    RETURN trim(caps(SUBSTRING(texto, 1, 1)) + LOWER(SUBSTRING(texto, 2, LENGTH(texto)))).
END.

/*********fun‡Æo para primeira letra de cada palavra ficar em maiuscula***********/
FUNCTION primeira-Uper RETURNS char (INPUT texto AS char):
    DEFINE VARIABLE i AS INTEGER     NO-UNDO.
    texto = trim(caps(SUBSTRING(texto, 1, 1)) + LOWER(SUBSTRING(texto, 2, LENGTH(texto)))).
    DO i = 1 TO LENGTH(texto):
        IF SUBSTRING(texto, i, 1) = " " THEN DO:
            texto = SUBSTRING(texto, 1, i) + uperinicio(SUBSTRING(texto, i + 1, length(texto))).
        END.
    END.
    RETURN texto.
END.

/*******fun‡Æo para converter um inteiro em numero romano*****************/
FUNCTION romano RETURNS char (INPUT numero AS int):
    IF numero > 0 AND numero < 4000 THEN DO:
        DEFINE VARIABLE i AS INTEGER INIT 13 NO-UNDO.
        DEFINE VARIABLE romano AS CHARACTER  EXTENT 13 NO-UNDO INITIAL ['I', 'IV', 'V', 'IX', 'X', 'XL', 'L', 'XC', 'C',  'CD', 'D', 'CM', 'M'].
        DEFINE VARIABLE inteiro AS INTEGER   EXTENT 13 NO-UNDO INITIAL [ 1,   4,    5,   9,    10,  40,   50,  90,   100,  400,  500, 900,  1000].
        DEFINE VARIABLE convertido AS CHARACTER   NO-UNDO.
        DO WHILE i > 0:
            DO WHILE numero >= inteiro[i]:
                ASSIGN
                    numero = numero - inteiro[i]
                    convertido = convertido + romano[i].
            END.
            i = i - 1.
        END.
        RETURN convertido.
    END.
END.

/**************gerar numero por extenso**********************************/
FUNCTION getExtenso RETURNS CHAR (INPUT number AS INT64):
    DEFINE VARIABLE extenso AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE numero AS CHARACTER  EXTENT 19 NO-UNDO INITIAL ['um', 'dois', 'trˆs', 'quatro', 'cinco', 'seis', 'sete', 'oito', 'nove',  'dez', 'onze', 'doze', 'treze', 'quatorze', 'quinze', 'dezesseis', 'dezessete', 'dezoito', 'dezenove'].
    DEFINE VARIABLE numerodec AS CHARACTER  EXTENT 8 NO-UNDO INITIAL ['vinte', 'trinta', 'quarenta', 'cinquenta', 'sessenta', 'setenta', 'oitenta', 'noventa'].
    DEFINE VARIABLE numerocen AS CHARACTER  EXTENT 9 NO-UNDO INITIAL ['cento', 'duzentos', 'trezentos', 'quatrocentos', 'quinhentos', 'seiscentos', 'setecentos', 'oitocentos', 'novecentos'].
    
    IF number = 0 THEN RETURN "".
    ELSE IF number > 0 AND number <= 19  THEN DO:
        extenso = numero[number] + " ".
    END.
    ELSE IF number >= 20 AND number <= 99  THEN DO:
         If (number Mod 10) = 0 THEN  extenso = numerodec[int64(TRUNCATE((number / 10) - 1, 0)) ] + " ".
         ELSE extenso = numerodec[int64(TRUNCATE((number / 10) - 1, 0)) ] + " e " + getExtenso(number Mod 10) + " ".
    END.
    ELSE IF number = 100  THEN DO:
         extenso = "cem".
    END.
    ELSE IF number > 100 AND number <= 999  THEN DO:
        If (number Mod 100) = 0 THEN extenso = numerocen[int64(TRUNCATE(number / 100, 0))] + " ".
        ELSE extenso = numerocen[int64(TRUNCATE(number / 100, 0))] + " e " + getExtenso(number Mod 100).
    END.
    ELSE IF number >= 1000 AND number <= 1999  THEN DO:
        IF (number Mod 1000) = 0 THEN "mil".
        ELSE IF (number Mod 1000) <= 100 THEN extenso = "mil e " + getExtenso(number Mod 1000).
        ELSE extenso = "mil, " + getExtenso(number Mod 1000).
    END.
    ELSE IF number >= 2000 AND number <= 999999  THEN DO:
        IF (number Mod 1000) = 0 THEN extenso = getExtenso(int64(TRUNCATE(number / 1000, 0))) + "mil".
        ELSE IF  (number Mod 1000) <= 100 THEN extenso = getExtenso(int64(TRUNCATE(number / 1000, 0))) + "mil e " + getExtenso(number Mod 1000).
        ELSE extenso = getExtenso(int64(TRUNCATE(number / 1000, 0))) + "mil, " + getExtenso(number Mod 1000).
    END.
    ELSE IF number >= 1000000 AND number <= 1999999  THEN DO:
        IF (number Mod 1000000) = 0 THEN extenso = "um milhÆo".
        ELSE IF  (number Mod 1000000) <= 100 THEN extenso = getExtenso(int64(TRUNCATE(number / 1000000, 0))) + "MilhÆo e " + getExtenso(number Mod 1000000).
        ELSE extenso = getExtenso(int64(TRUNCATE(number / 1000000, 0))) + "milhÆo, " + getExtenso(number Mod 1000000).
    END.
    ELSE IF number >= 2000000 AND number <= 999999999  THEN DO:
        IF (number Mod 1000000) = 0 THEN extenso = getExtenso(int64(TRUNCATE(number / 1000000, 0))) + " milhäes".
        ELSE IF (number Mod 1000000) <= 100 THEN extenso = getExtenso(int64(TRUNCATE(number / 1000000, 0))) + " milhäes e " + getExtenso(number Mod 1000000).
        ELSE extenso = getExtenso(int64(TRUNCATE(number / 1000000, 0))) + "milhäes, " + getExtenso(number Mod 1000000).
    END.
    ELSE IF number >= 1000000000 AND number <= 1999999999  THEN DO:
        IF (number Mod 1000000000) = 0 THEN extenso = "um bilhÆo".
        ELSE IF (number Mod 1000000000) <= 100 THEN extenso = getExtenso(int64(TRUNCATE(number / 1000000000, 0))) + "bilhÆo e " + getExtenso(number Mod 1000000000).
        ELSE extenso = getExtenso(int64(TRUNCATE(number / 1000000000, 0))) + "bilhÆo, " + getExtenso(number Mod 1000000000).
    END.
    ELSE IF number >= 2000000000 AND number <= 999999999999  THEN DO:
        IF (number Mod 1000000000) = 0 THEN extenso = getExtenso(int64(TRUNCATE(number / 1000000000, 0))) + " bilhäes".
        ELSE IF (number Mod 1000000000) <= 100 THEN extenso = getExtenso(int64(TRUNCATE(number / 1000000000, 0))) + "bilhäes e " + getExtenso(number Mod 1000000000).
        ELSE extenso = getExtenso(int64(TRUNCATE(number / 1000000000, 0))) + "bilhäes, " + getExtenso(number Mod 1000000000).
    END.
    ELSE DO:
        MESSAGE "valor " number " ainda nÆo implementado"
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
    END.
    RETURN replace(extenso, "  ", " ").
END FUNCTION.

/**********************converter valor para reais**************************************/
FUNCTION getExtensoReais RETURNS CHAR (INPUT valor AS DECIMAL):
    DEFINE VARIABLE reais AS CHAR       NO-UNDO.
    DEFINE VARIABLE centavos AS CHAR       NO-UNDO.
    DEFINE VARIABLE conector AS CHAR       NO-UNDO.
    IF INT64(TRUNCATE(valor, 0)) = 0 THEN reais = "".
    ELSE IF INT64(TRUNCATE(valor, 0)) = 1 THEN reais = "real ".
    ELSE reais = "reais ".
    IF INT((valor - truncate(valor, 0)) * 100) = 0 THEN "".
    ELSE IF INT((valor - truncate(valor, 0)) * 100) = 1 THEN centavos = "centavo ".
    ELSE centavos = "centavos ".
    IF INT((valor - truncate(valor, 0)) * 100) <> 0 AND INT64(TRUNCATE(valor, 0)) <> 0 THEN conector = "e ".
    ELSE conector = "".         
    RETURN getExtenso(INT64(TRUNCATE(valor, 0))) + reais + conector + getExtenso(INT((valor - truncate(valor, 0)) * 100)) + centavos.
END FUNCTION.



/**********************gerador de arquivo de log**************************************/
FUNCTION geralog RETURNS LOGICAL (INPUT texto AS CHAR, INPUT arquivo AS CHAR, INPUT OK AS LOGICAL):
    DEFINE VARIABLE i AS INTEGER     NO-UNDO.
    OUTPUT  TO value(arquivo) APPEND.
    DO i = 1 TO NUM-ENTRIES(texto, CHR(10)) :
        IF TRIM(ENTRY(i, texto, CHR(10))) <> "" THEN DO:
            PUT IF OK THEN "INFO - " ELSE "ERROR - "
                String(NOW, "99/99/9999 HH:MM:SS.SSS" ) FORMAT "x(23)"
                " - " 
                ENTRY(i, texto, CHR(10)) FORMAT "x(" + STRING(LENGTH(ENTRY(i, texto, CHR(10)))) + ")"
                SKIP.
        END.
    END.
    OUTPUT CLOSE.
END.

/**********************cria pasta**************************************/

FUNCTION criapasta RETURNS LOGICAL (INPUT pasta AS CHAR):
    assign file-info:file-name = pasta. 
    if file-info:full-pathname = ? then os-create-dir value(pasta).
end.

/**********************preencher texto**************************************/
FUNCTION completar RETURNS CHAR (INPUT valor AS CHAR, INPUT tamanho AS INT, INPUT carac AS CHAR):
    DEFINE VARIABLE i AS INTEGER     NO-UNDO.
    valor = TRIM(valor).
    DO i = 0 TO tamanho.
        IF LENGTH(valor) < tamanho THEN valor = carac + valor.
    END.
    RETURN valor.
end.

/**********************quebrar texto em linha texto**************************************/
FUNCTION quebratexto CHAR (INPUT valor AS CHAR, INPUT tamanho AS INT):
    DEFINE VARIABLE aux AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE i  AS INTEGER     NO-UNDO.
    /*valor = limpa-texto(valor).*/

    DO i = 1 TO NUM-ENTRIES(valor, " "):
        aux = aux + ENTRY(i, valor, " ") + " ".
        IF i MOD tamanho = 0 THEN DO:
            aux = aux + CHR(10) + CHR(13).
        END.
    END.

    RETURN aux.
end.











