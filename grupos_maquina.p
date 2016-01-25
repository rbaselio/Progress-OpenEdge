/*{U:\progress\excel.i}
    
        
ini-excel("").

para-excel("gm-estab", 1, "WHERE gm-estab.cc-codigo >= '500000'").

fim-excel(TRUE).*/
    
        
         
FOR EACH gm-estab WHERE gm-estab.cc-codigo >= '500000':
    /*DISP gm-estab WITH 1 COLUMN WIDTH 500.*/
    DELETE gm-estab.
END.
