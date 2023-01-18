#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function TECA01CSV
    Importação de atualização de cadastro de cliente com base CSV
    @type  Function
    @author João Mauricio
    @since 17/01/2023
    @param cArqOri, character, Caminho do arquivo a ser importado.
    @version 1.0
/*/
User Function TECA01CSV(cArqOri)    
    Local aLinhas    as Array
    Local cOrigem := 2 //importacao csv
    Local nLinha     as Numeric
    Local nTotLinhas as Numeric
    Local oArquivo   as Object
    Local cCodigo    as Character
    Local cLoja      as Character

    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
    //Se o arquivo pode ser aberto
    If (oArquivo:Open()) .and. !(oArquivo:EoF())
        //Definindo o tamanho da régua
        aLinhas := oArquivo:GetAllLines()
        nTotLinhas := Len(aLinhas)  

        If !fValidHeader(aLinhas[1])
            Return Nil
        EndIf

        //Enquanto tiver linhas
        For nLinha := 2 to nTotLinhas
            //transformando em array
            aLinha := StrTokArr2(aLinhas[nLinha], ";", .T. )

            cCodigo := aLinha[1]
            cLoja := aLinha[2]

            //instancia a classe de atualizar clientes
            oAtuCli := AtualizaCli():new(cOrigem,cCodigo,cLoja)  
            
            //Verifica se o CEP está em branco e atualiza o cliente.
            If Empty(aLinha[3])                 
                //Busca o CEP caso não esteja preenchido no csv.               
                oAtuCli:montaTela()  
            Else       
                oAtuCli:setCEP(aLinha[3])          
            EndIf
            //Faz a consulta na api dos correios
            oAtuCli:buscaCEP()  
         
            If oAtuCli:valida()
                oAtuCli:realizaAlteracao()       
            EndIf
         
            FwFreeObj(oAtuCli)
        Next nLinha
    EndIf

    //Fecha o arquivo
    oArquivo:Close()
Return nil

/*/{Protheus.doc} fValidHeader
    Verifica se o header do arquivo csv está de acordo com o layout proposto.
    @type  Static Function
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
    @param aLinha, array, linha com o cabeçalho do arquivo csv.
    @return lRet, logical, Validação do header.
/*/
Static Function fValidHeader(aLinha)
    Local nHeader as Numeric   
    Local aHeader as Array

    aHeader := StrTokArr2(aLinha, ",", .T. )
    aLayout := {'CODIGO', 'LOJA', 'CEP', 'ENDERECO', 'COMPLEMENTO', 'BAIRRO', 'CIDADE', 'UF'}

    For nHeader := 1 to len(aHeader)
        If Alltrim(aHeader[nHeader]) <> aLayout[nHeader]
            MsgAlert("Layout incompativel, favor validar o arquivo para importação: "+cArqOri+".", "Layout de importação")
            Return .F.
        EndIf
    Next nHeader

Return .T.
