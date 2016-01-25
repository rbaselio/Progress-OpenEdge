/****************FUN€åES PARA EXCEL**********************/
/*variaveis excel*/
DEFINE VARIABLE excel   as COM-HANDLE.
DEFINE VARIABLE arquivo AS COM-HANDLE.
DEFINE VARIABLE aba     AS COM-HANDLE.
DEFINE VARIABLE lin     AS INTEGER INIT 1    NO-UNDO.
DEFINE VARIABLE colu    AS INTEGER INIT 1    NO-UNDO.


/*fun‡Æo para converter colunas em letras para o excel*/
FUNCTION letra RETURNS CHAR (INPUT valor AS INT):
    IF valor <= 26 THEN RETURN CHR(valor + 64).
    ELSE IF valor MOD 26 = 0 THEN RETURN letra(int(TRUNCATE(((valor - 1) / 26), 0))) + letra(26).
    RETURN letra(int(TRUNCATE((valor / 26), 0))) + letra(valor MOD 26).
END FUNCTION.

/*retorna um celula */
FUNCTION celula RETURNS CHAR (INPUT coluna AS INT, INPUT linha AS INT):
    RETURN letra(coluna) + STRING(linha).
END FUNCTION.

/*substitui o conteudo de toda a planilha*/
FUNCTION preencher RETURNS LOGICAL (INPUT origem AS CHAR, INPUT destino AS CHAR):
    aba:cells:REPLACE( origem, destino, 2, 1, FALSE, FALSE, FALSE).
    RETURN TRUE.
END FUNCTION.


FUNCTION somar RETURNS CHAR (INPUT linha-ini AS INT, INPUT coluna-ini AS INT, INPUT linha-fim AS INT, INPUT coluna-fim AS INT):
    RETURN "=sum(" + letra(coluna-ini) + STRING(linha-ini) + ":" + letra(coluna-fim) + STRING(linha-fim) + ")".
END FUNCTION.


/*inicia aplica‡Æo*/
FUNCTION ini-excel RETURNS LOGICAL (INPUT dt AS char ):
    CREATE 'Excel.Application' excel.
    ASSIGN
        excel:VISIBLE = FALSE
        excel:DisplayAlerts  = excel:VISIBLE
        excel:ScreenUpdating = excel:DisplayAlerts.
        arquivo = excel:Workbooks:add(dt).
    IF dt = "" THEN DO:
        DO WHILE arquivo:sheets:COUNT > 1:
            arquivo:sheets:item(arquivo:sheets:COUNT):DELETE.
        END.
    END.
    aba = arquivo:sheets:ITEM(1).
    aba:activate.
    lin = 1.
    /*aba:Range("a1"):SELECT.*/
    RETURN TRUE.
END FUNCTION.

FUNCTION imagem RETURNS LOGICAL (INPUT celula AS COM-HANDLE,  INPUT img AS char, INPUT tamanho AS DEC ):
    celula:Select.
    aba:Pictures:Insert(img):Select.
    excel:Selection:ShapeRange:ScaleWidth(tamanho / 100 ,FALSE,FALSE).
    excel:Selection:ShapeRange:ScaleHeight(tamanho / 100 ,FALSE,FALSE).
    excel:Selection:Placement = 1.
END.

/*congela na linha selecionada para gerar cabe‡alhos fixos*/
FUNCTION congelar RETURNS LOGICAL (INPUT linha AS int):
    aba:cells(linha + 1, 1):SELECT.
    ASSIGN
        excel:ActiveWindow:FreezePanes = TRUE.
    aba:cells(1, 1):SELECT.
    RETURN TRUE.
END FUNCTION.

/*retonna um range de celulas*/
FUNCTION range RETURNS CHAR (INPUT linhaini AS INT, INPUT colunaini AS INT, INPUT linhafim AS INT , INPUT colunafim AS INT):
    RETURN celula(colunaini, linhaini) + ":" + celula(colunafim, linhafim).
END FUNCTION.

PROCEDURE borda-celula.
    ASSIGN
        excel:Selection:Borders(7):LineStyle = 1
        excel:Selection:Borders(8):LineStyle = 1
        excel:Selection:Borders(9):LineStyle = 1
        excel:Selection:Borders(10):LineStyle = 1
        excel:Selection:Borders(11):LineStyle = 0
        excel:Selection:Borders(12):LineStyle = 0  .

END PROCEDURE.

/*centraliza cria bordas e colore as celulas*/
FUNCTION alinhar RETURNS LOGICAL (INPUT lin-fim AS INT, INPUT colu-fim AS INT):
    DEFINE VARIABLE cor AS LOGICAL  INIT yes   NO-UNDO.
    DEFINE VARIABLE i AS INTEGER     NO-UNDO.
    DEFINE VARIABLE l AS INTEGER     NO-UNDO.

    aba:Range(range(1, 1, lin-fim, colu-fim)):Select.
    ASSIGN
        excel:Selection:Borders(5):LineStyle = -4142
        excel:Selection:Borders(6):LineStyle = -4142
        excel:Selection:Borders(8):LineStyle = 1
        excel:Selection:Borders(8):Weight = 2
        excel:Selection:Borders(9):LineStyle = 1
        excel:Selection:Borders(9):Weight = 2
        excel:Selection:Borders(10):LineStyle = 1
        excel:Selection:Borders(10):Weight = 2
        excel:Selection:Borders(11):LineStyle = 1
        excel:Selection:Borders(11):Weight = 2
        excel:Selection:Borders(12):LineStyle = 1
        excel:Selection:Borders(12):Weight = 2.


    DO i = 1 TO lin-fim:
        aba:Rows(i):Entirerow:AutoFit. 
        aba:Rows(i):VerticalAlignment = 2.
    END.

    DO l = 1 TO colu-fim:
        aba:COLUMNS(l):WrapText = FALSE.
        aba:COLUMNS(l):EntireColumn:AutoFit.
    END.

    aba:Range(range(1, 1, 1, 1)):Select.
       
    RETURN TRUE.
END FUNCTION.

/*insere imagem no arquivo*/
FUNCTION insert-imagem RETURNS LOGICAL (INPUT linha AS INT, INPUT coluna AS INT, INPUT tamanho AS dec, INPUT imagem AS CHAR):
    aba:cells(linha,coluna):SELECT.
    aba:Pictures:Insert(imagem).
    aba:Pictures:WIDTH = tamanho.
    RETURN TRUE.
END FUNCTION.

/*muda para uma aba selecionada*/
FUNCTION muda-aba RETURNS LOGICAL (INPUT pasta AS INT):
    ASSIGN
        aba = arquivo:sheets:ITEM(pasta).
    aba:activate.
    aba:cells(1, 1):SELECT.
    RETURN TRUE.
END FUNCTION.

/*cria uma copia de uma aba*/
FUNCTION copy-aba RETURNS LOGICAL (INPUT nome-origem AS CHAR, INPUT nome-dest AS CHAR):
    DEFINE VARIABLE after  AS COM-HANDLE.
    ASSIGN
        lin = 1
        aba = arquivo:sheets:ITEM(nome-origem)
        after = arquivo:sheets:item(arquivo:sheets:COUNT).
    aba:activate.
    aba:Copy( , after).
    ASSIGN
        aba = arquivo:sheets:ITEM(arquivo:sheets:COUNT)
        aba:NAME = nome-dest.
    aba:cells(1, 1):SELECT.
    RETURN TRUE.
END.

/*cria uma nova aba*/
FUNCTION add-aba RETURNS LOGICAL (INPUT nome AS CHAR):
    DEFINE VARIABLE after  AS COM-HANDLE.
    ASSIGN
        lin = 1
        aba = arquivo:sheets:ADD
        after = arquivo:sheets:item(arquivo:sheets:COUNT)
        aba:NAME = nome.
    aba:MOVE( , after).
    aba:activate.
    aba:cells(1, 1):SELECT. 
    RETURN TRUE.
END FUNCTION.


FUNCTION inserir-linha RETURNS LOGICAL (INPUT linha AS int):
    aba:Rows(linha):Insert(,1).
END FUNCTION.

/*salva a planilha*/
FUNCTION salva-excel RETURNS LOGICAL(INPUT nomeArquivo AS CHAR, INPUT extencao AS CHAR, INPUT abrir AS LOGICAL):
    IF extencao = "PDF" THEN arquivo:sheets:item(1):ExportAsFixedFormat(0, nomeArquivo).
    ELSE aba:SAVEas (nomeArquivo, 56, "", "", FALSE, FALSE).
    IF abrir THEN OS-COMMAND SILENT VALUE(nomeArquivo). 
END FUNCTION.

/*finaliza aplica‡Æo*/
FUNCTION fim-excel RETURNS LOGICAL(INPUT visivel AS LOGICAL):
    aba = arquivo:sheets:ITEM(1).
    aba:activate.
    /*aba:cells(1, 1):SELECT. */
    ASSIGN
        excel:VISIBLE = visivel
        excel:DisplayAlerts  = excel:VISIBLE
        excel:ScreenUpdating = excel:DisplayAlerts.
    IF NOT visivel THEN do:
        arquivo:CLOSE(FALSE, FALSE).
        excel:QUIT.
    END.
    RELEASE OBJECT arquivo.
    RELEASE OBJECT aba.
    RELEASE OBJECT excel.
    RETURN TRUE.
END FUNCTION.


/**********************exportar tabela direto para excel**************************************/
FUNCTION para-excel RETURNS LOGICAL (INPUT tabela AS CHARACTER, INPUT inicio AS INT, INPUT clausula AS c):
    DEFINE VARIABLE i      AS INTEGER     NO-UNDO.
    DEFINE VARIABLE qh     AS HANDLE.
    DEFINE VARIABLE bh     as handle.
    DEFINE VARIABLE iCont  as int.

    CREATE QUERY qh.
    CREATE BUFFER bh FOR TABLE tabela.
    qh:SET-BUFFERS(bh). 
    qh:QUERY-PREPARE("for each " + tabela + " " + clausula).
    qh:QUERY-OPEN.

    ASSIGN
        lin = inicio
        colu = 1.
    do iCont = 1 to bh:num-fields:
        ASSIGN
            aba:Range(celula(colu,lin)):VALUE =  "'" + bh:buffer-field(iCont):label
            colu = colu + 1.
    END.
    ASSIGN
        colu = 1
        lin = lin + 1.
    DO WHILE (qh:GET-NEXT = YES):
        REPEAT i = 1 TO bh:num-fields.
            ASSIGN
                aba:Range(celula(colu,LIN)):VALUE = STRING(bh:BUFFER-FIELD(i):BUFFER-VALUE)
                colu = colu + 1.
        END.
        ASSIGN
            colu = 1
            lin = lin + 1.
    END.
    /*alinhar(inicio, bh:num-fields, lin).*/

END FUNCTION.





