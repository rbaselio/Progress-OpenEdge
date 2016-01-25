DEFINE VARIABLE path-pdf AS CHARACTER   NO-UNDO.
DEFINE VARIABLE pdf AS COM-HANDLE      NO-UNDO.
DEFINE VARIABLE pdfop AS COM-HANDLE      NO-UNDO.
DEFINE VARIABLE impressora-padrao AS CHAR      NO-UNDO.


FUNCTION impressora RETURNS CHAR (INPUT nome AS char):
    DEFINE VARIABLE  impressoras AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE posicao AS INTEGER     NO-UNDO.
    impressoras = SESSION:GET-PRINTERS( ) + ",".
    DO WHILE INDEX(impressoras, ",") <> 0:
        posicao = INDEX(impressoras, ",").
        IF  index(Substring(impressoras, 1, posicao - 1), nome) <> 0 THEN RETURN Substring(impressoras, 1, posicao - 1).
        impressoras = SUBSTRING(impressoras, posicao + 1, LENGTH(impressoras)).
    END.
END FUNCTION.


FUNCTION ini-pdf RETURNS LOGICAL (INPUT pasta AS char, INPUT nome AS CHAR):
    DOS Silent VALUE("taskkill /F /IM PDFCreator.exe /T").
    CREATE "PDFCreator.clsPDFCreator" pdf NO-ERROR.
    IF pdf = ? THEN DO:
        MESSAGE "Para gerar este PDF ‚ necessario instalar o PDFCreator!" 
            CHR(10)
            "Contate do Depto. de TI."
            VIEW-AS ALERT-BOX INFO BUTTONS OK.
        RETURN FALSE.
    END.
    path-pdf = pasta + nome.
    IF  SEARCH(path-pdf) <> ? THEN DOS Silent VALUE("DEL " + path-pdf).
    CREATE "PDFCreator.PDFCreatorOptions" pdfop NO-ERROR.
    PDF:cStart(,).
    ASSIGN
        pdfop = PDF:cOptions
        PDFop:AutosaveDirectory = pasta
        PDFop:AutosaveFilename = nome
        PDFop:UseAutosave = 1
        PDFop:UseAutosaveDirectory = 1
        PDFop:AutosaveFormat = 0
        PDF:cOptions = PDFop
        impressora-padrao = PDF:cDefaultPrinter
        PDF:cDefaultPrinter = "PDFCreator"
        PDF:cPrinterStop = FALSE.
END FUNCTION.

FUNCTION imprimir-pdf RETURNS LOGICAL (INPUT arquivo AS char):
    PDF:cPrintFile(arquivo).
END FUNCTION.


FUNCTION fim-pdf RETURNS LOGICAL (INPUT visivel AS LOGICAL):
    DO WHILE SEARCH(path-pdf) = ?: 
    END.
    pdf:cDefaultprinter = impressora-padrao.
    RELEASE OBJECT pdf.
    DOS Silent VALUE("taskkill /F /IM PDFCreator.exe /T").
    IF visivel THEN DOS SILENT START VALUE(path-pdf).
    RETURN TRUE.
END FUNCTION.


