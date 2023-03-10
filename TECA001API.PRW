#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'

WSRESTFUL AtualizaCliente DESCRIPTION "Atualiza??o de clientes"

WSDATA codigo as String
WSDATA loja   as String
WSDATA cep    as String


WSMETHOD PUT AtualizaPorCEP;
    DESCRIPTION "Atualiza endere?o do cliente com base na consulta da API dos correios.";
    WSSYNTAX "api/v1/atualizacliente/cep" ;
    PATH "api/v1/atualizacliente/cep" ; 

END WSRESTFUL

WSMETHOD PUT AtualizaPorCEP WSRECEIVE codigo, loja, cep WSSERVICE AtualizaCliente
    Local cCEP    := ::cep
    Local cCodigo := ::codigo
    Local cLoja   := ::loja
    Local cOrigem := 3 //ws
    Local oRetJson := nil
    Local lPost := .T.
    Local cIdent := ''

    // define o tipo de retorno do m?todo
	::SetContentType("application/json")
    
    //Valida??o das variaveis
    If Empty(cCEP) .or. Empty(cCodigo) .or. Empty(cLoja) 
        SetRestFault(400,EncodeUTF8('Informa??es obrigat?rias: cep, codigo e loja do cliente.')) 
        Return .F.
    Endif
  
    If lPost
        oAtuCli := AtualizaCli():new(cOrigem,cCodigo,cLoja)    
        oAtuCli:setCEP(cCEP)    
        oAtuCli:buscaCEP()

        If oAtuCli:valida() .and. oAtuCli:realizaAlteracao()         
            oRetJson := oAtuCli:getoJson()
            oRetJson['codigo'] := cCodigo
            oRetJson['loja'] := cLoja  
            oRetJson := EncodeUTF8(oRetJson:toJson())
            lPost := .T.
        Else
            lPost := .F.
        EndIf 
    EndIf

    //Tratamento de erros
    If !lPost
        DbSelectArea('SA1')
        SA1->(DbSetOrder(1))
        If SA1->(DbSeek(xFilial('SA1')+cCodigo+cLoja))
            cIdent := SA1->A1_NOME
        else
            cIdent := 'N?o identificado'
        Endif
        conout('Falha na atualiza??o de endere?o do cliente : '+Alltrim(cIdent)+', por favor aguarde alguns instantes e tente novamente.')        
        SetRestFault(400 ,EncodeUTF8('N?o foi possivel atualizar o cliente.'))
        lPost := .F.
    EndIf 

    If lPost
        ::SetResponse(oRetJson)  
    EndIf

Return lPost
