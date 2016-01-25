/**********************************FUNÄÂES COM DATAS**********************************************/
DEFINE VARIABLE meses AS CHARACTER  EXTENT 12 NO-UNDO INITIAL ['janeiro', 'fevereiro', 'maráo', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro',  'outubro', 'novembro', 'dezembro'].
DEFINE VARIABLE meses-ing AS CHARACTER  EXTENT 12 NO-UNDO INITIAL ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'].
DEFINE VARIABLE meses-esp AS CHARACTER  EXTENT 12 NO-UNDO INITIAL ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto','septiembre ','octubre','noviembre', 'diciembre'].

/*funá∆o para encontrar o ultimo dia do màs*/
FUNCTION ultimo-dia RETURNS DATE (INPUT dt AS DATE ): 
    IF dt = ? THEN RETURN (?). 
    RETURN (DATE(MONTH(dt),28,YEAR(dt)) + 4 - DAY(DATE(MONTH(dt),28,YEAR(dt)) + 4) ). 
END FUNCTION.

/*funá∆o para encontrar o primeiro dia do màs*/
FUNCTION primeiro-dia RETURNS DATE (INPUT dt AS DATE): 
     IF dt = ? THEN RETURN  ( ? ). 
     RETURN (DATE(month(dt),01,YEAR(dt))). 
END FUNCTION. 

/*calcula o feriado da pascoa*/
FUNCTION pascoa RETURNS DATE (INPUT data AS DATE):
    DEFINE VARIABLE a   AS INTEGER NO-UNDO.
    DEFINE VARIABLE b   AS INTEGER NO-UNDO.
    DEFINE VARIABLE c   AS INTEGER NO-UNDO.
    DEFINE VARIABLE d   AS INTEGER NO-UNDO.
    DEFINE VARIABLE e   AS INTEGER NO-UNDO.
    DEFINE VARIABLE f   AS INTEGER NO-UNDO.
    DEFINE VARIABLE g   AS INTEGER NO-UNDO.
    DEFINE VARIABLE h   AS INTEGER NO-UNDO.
    DEFINE VARIABLE i   AS INTEGER NO-UNDO.
    DEFINE VARIABLE k   AS INTEGER NO-UNDO.
    DEFINE VARIABLE L   AS INTEGER NO-UNDO.
    DEFINE VARIABLE m   AS INTEGER NO-UNDO.
    DEFINE VARIABLE ano AS INTEGER NO-UNDO.
    DEFINE VARIABLE mes AS INTEGER NO-UNDO.
    DEFINE VARIABLE dia AS INTEGER NO-UNDO.

    ASSIGN
        ano = year(data)
        a = ano mod 19
        b = truncate(ano / 100, 0)
        c = ano mod 100
        d = truncate(b / 4, 0)
        e = b mod 4
        f = TRUNCATE((b + 8 ) / 25, 0)
        g = TRUNCATE((b - f + 1) / 3, 0)
        h = (19 * a + b - d - g + 15) MOD 30
        i = truncate(c / 4, 0)
        k = c mod 4
        L = (32 + 2 * e + 2 * i - h - k) MOD 7
        m = truncate((a + 11 * h + 22 * L) / 451, 0)
        mes = (TRUNCATE((h + l - 7 * m + 114) / 31, 0))
        dia = (( h + l - 7 * m + 114) MOD 31) + 1.
    RETURN DATE(mes, dia, ano).
END FUNCTION.

/*calcula o feriado de corpus-crist*/
FUNCTION corpus-crist RETURNS DATE (INPUT data AS DATE):
    RETURN pascoa(data) + 60.
END FUNCTION.

/*calcula o feriado de sexta-feira santa*/
FUNCTION sexta-santa RETURNS DATE (INPUT data AS DATE):
    RETURN pascoa(data) - 2.
END FUNCTION.

/*verifica se o dia Ç util ou n∆o*/
FUNCTION dia-util RETURNS logical (INPUT data AS DATE):
    DEFINE VARIABLE dia AS integer EXTENT 10 NO-UNDO INITIAL [1, 21, 1, 9, 26, 7,  2, 15, 20, 25]. 
    DEFINE VARIABLE mes AS INTEGER EXTENT 10 NO-UNDO INITIAL [1,  4, 5, 7,  7, 9, 11, 11, 11, 12].
    DEFINE VARIABLE i AS INTEGER  INIT 1   NO-UNDO.
    IF WEEKDAY(data) = 1 OR 
       WEEKDAY(data) = 7 OR 
       data = corpus-crist(data) OR
       data = sexta-santa(data) THEN RETURN false.
    ELSE DO WHILE i < 11: 
        IF DAY(data) = dia[i] AND MONTH(data) = mes[i] THEN RETURN false.
        i = i + 1.
    END.
    RETURN true.
END FUNCTION.

/*funá∆o para encontrar o primeiro dia util do màs*/
FUNCTION pri-dia-util RETURNS DATE (INPUT data AS DATE):
    data = primeiro-dia(data).
    DO WHILE dia-util(data) = FALSE:
        data = data + 1.
    END.
    RETURN data.
END FUNCTION.

/*funá∆o para encontrar o ultimo dia util do màs*/
FUNCTION ult-dia-util RETURNS DATE (INPUT data AS DATE):
    data = ultimo-dia(data).
    DO WHILE dia-util(data) = FALSE:
        data = data - 1.
    END.
    RETURN data.
END FUNCTION.

FUNCTION dias-uteis RETURNS int (INPUT data AS DATE):
    DEFINE VARIABLE fim  AS DATE    NO-UNDO.
    DEFINE VARIABLE dias AS INTEGER NO-UNDO.
    ASSIGN 
        data = primeiro-dia(data)
        fim    = ultimo-dia(data).
    DO WHILE data <= fim:
        IF dia-util(data) = TRUE THEN
            ASSIGN
                dias = dias + 1.
        ASSIGN
            data = data + 1.
    END.
    RETURN dias.
END FUNCTION.

FUNCTION semanaano RETURNS INT (INPUT dSomeDate AS DATE):
    DEFINE VARIABLE dStart AS DATE NO-UNDO.
    ASSIGN dStart = DATE(1,1,YEAR(dSomeDate))
           dStart = dStart + (8 - WEEKDAY(dStart)).
    IF dStart > dSomeDate THEN
        RETURN 1.
    ELSE
        RETURN 2 + INTEGER( TRUNCATE(INTEGER(dSomeDate - dStart) / 7 , 0)).
END FUNCTION.

FUNCTION semanames RETURNS INT (INPUT dSomeDate AS DATE):
    DEFINE VARIABLE dStart AS DATE NO-UNDO.
    ASSIGN 
        dStart = DATE(MONTH(dSomeDate),1,YEAR(dSomeDate))
        dStart = dStart + (8 - WEEKDAY(dStart)).
    IF dStart > dSomeDate THEN RETURN 1.
    ELSE RETURN 2 + INTEGER( TRUNCATE(INTEGER(dSomeDate - dStart) / 7 , 0)).
END FUNCTION.

FUNCTION DataExtenso RETURNS CHAR (INPUT valor AS DATE):
    RETURN STRING(DAY(valor), "99 de ") + meses[MONTH(valor)] + STRING(YEAR(valor), " de 9999").
END FUNCTION.

FUNCTION NomeMes RETURNS CHAR (INPUT valor AS int):
    RETURN  meses[valor].
END FUNCTION.

FUNCTION DataExtenso-ing RETURNS CHAR (INPUT valor AS DATE):
    RETURN meses-ing[MONTH(valor)] + STRING(DAY(valor), " 99. ") +  STRING(YEAR(valor), "9999").
END FUNCTION.

FUNCTION DataExtenso-esp RETURNS CHAR (INPUT valor AS DATE):
    RETURN STRING(DAY(valor), "99 de ") + meses-esp[MONTH(valor)] + STRING(YEAR(valor), " 9999").
END FUNCTION.



