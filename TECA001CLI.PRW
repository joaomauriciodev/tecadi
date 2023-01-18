#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} AtualizaCli
    Classe de atualização de cliente
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
    /*/
Class AtualizaCli FROM LongClassName
    Data cCEP    as Character
    Data cCodigo as Character
    Data cLoja   as Character
    Data cOrigem as Character
    Data oJson   as Object

    METHOD New(cOrigem,cCodigo,cLoja) CONSTRUCTOR

    METHOD setCEP(cCEP)
    METHOD getoJson()

    METHOD montaTela()
    METHOD buscaCEP()
    METHOD valida()
    METHOD realizaAlteracao()
    
EndClass

METHOD New(cOrigem,cCodigo,cLoja) CLASS AtualizaCli
    

	::cOrigem := cOrigem
    ::cCodigo := cCodigo
    ::cLoja   := cLoja
    ::cCEP    := ''
    ::oJson   := JsonObject():New()

Return Self

/*/{Protheus.doc} montaTela
    Dialog para digitação do CEP.
    @type  Method
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
/*/
METHOD montaTela() CLASS AtualizaCli
    Local aAreaSA1  := GetArea( 'SA1' )
    Local aButtons  := Array(0)
    Local bProcessa := {|| oModal:DeActivate() }
    Local cCEP      := Space(8)
    Local oContainer as Object
    Local oModal     as Object

    //auto healing
    cCodigo := alltrim(::cCodigo) 
    cLoja := alltrim(::cLoja) 
    
    Aadd(aButtons, {"", 'Consultar e Atualizar Cadastro.',bProcessa, , , .T., .F.}) 

    oModal := FWDialogModal():New()
    oModal:SetEscClose(.T.)
    oModal:setTitle( 'Atualizar Endereço por CEP (digitação)' )
    oModal:setSubTitle( 'Consulta do CEP utilizando os Correios.' )
     
    //Seta a largura e altura da janela em pixel
    oModal:setSize(120, 200)
    //Cria o Dialog
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oModal:addButtons(aButtons)
    oContainer:= TPanel():New(, , , oModal:getPanelMain())
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    TSay():New(5 , 5 , {|| "Nome do Cliente:"}                                           , oContainer, , , , , , .T., , , 200, 30, , , , , , .T.)
    TSay():New(5 , 60, {|| Posicione( 'SA1' ,1,xFilial( 'SA1' )+cCodigo+cLoja,"A1_NOME")}, oContainer, , , , , , .T., , , 200, 30, , , , , , .T.)
    TSay():New(15, 5 , {|| "Código:"}                                                    , oContainer, , , , , , .T., , , 200, 30, , , , , , .T.)
    TSay():New(15, 60, {|| cCodigo}                                                      , oContainer, , , , , , .T., , , 200, 30, , , , , , .T.)
    TSay():New(25, 5 , {|| "Loja:"}                                                      , oContainer, , , , , , .T., , , 200, 30, , , , , , .T.)
    TSay():New(25, 60, {|| cLoja}                                                        , oContainer, , , , , , .T., , , 200, 30, , , , , , .T.)

    //Input do CEP.
    TSay():New(38, 5 , {|| "CEP (sem traço): "}, oContainer, , , , , , .T., , , 200, 60, , , , , , .T.)
    TGet():New(35, 60, {| u | If( PCount() == 0, cCEP, cCEP := u)},oContainer, ;
     060, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCEP",,,,.T.)

    oModal:Activate()

    RestArea(aAreaSA1)
    //Seta o CEP
    ::setCEP(cCEP)

Return Nil

/*/{Protheus.doc} buscaCEP
    Consulta o CEP informado na api dos correios.
    @type Method
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
/*/
METHOD buscaCEP() CLASS AtualizaCli
    Local oRestClient as object
    Local cURL  := "https://viacep.com.br"
   
    oRestClient := FWRest():New(cURL)
    oRestClient:setPath("/ws/"+::cCEP+"/json/")
    
    if oRestClient:Get()
        cApiRet := oRestClient:GetResult()
        cJson := DecodeUTF8(cApiRet, "cp1252")
        ::oJson:FromJson(cJson)         
    else      
        ::oJson['erro'] := oRestClient:GetLastError()         
    endif   

Return Nil

/*/{Protheus.doc} setCEP
    Set do atributo cCEP
    @type Method
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
/*/
METHOD setCEP(cCEP) CLASS AtualizaCli      
    ::cCEP := Alltrim(cCEP)
Return Nil

/*/{Protheus.doc} getoJson
    Get do atributo oJson
    @type Method
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
/*/
METHOD getoJson() CLASS AtualizaCli      

Return ::oJson

/*/{Protheus.doc} valida
    Validação dos dados recebidos pela api dos correios e cep informado.
    @type Method
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
/*/
METHOD valida() CLASS AtualizaCli
    If Empty(::cCEP) 
        u_TECA01MSG('CEP não informado.', ::cOrigem)        
        Return .F.
    EndIf

    If ::oJson:HasProperty('erro')        
        u_TECA01MSG('O CEP '+::cCEP+' informado no cadastro de cliente não consta na base de dados da consulta pública.', ::cOrigem)        
        Return .F.
    EndIf
Return .T.



/*/{Protheus.doc} realizaAlteracao
    Execução da atualização do cadastro de cliente com o retorno da api dos correios.
    Uso do execauto CRMA980.
    @type  Method
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
/*/
METHOD realizaAlteracao() CLASS AtualizaCli
    Local aAreaSA1 := GetArea( 'SA1' )
    Local aSA1Auto := Array(0)
    Local lRet     := .F.
    Local nOpcAuto := 4

    Private lMsErroAuto := .F. 

    //auto healing
    cCodigo := alltrim(::cCodigo) 
    cLoja := alltrim(::cLoja) 
    oJson := ::oJson

    DbSelectArea('SA1')
    SA1->(DbSetOrder(1))
    If SA1->(DbSeek(xFilial('SA1')+cCodigo+cLoja))

        aadd(aSA1Auto, {"A1_COD"    , SA1->A1_COD                                                      , Nil})
        aadd(aSA1Auto, {"A1_LOJA"   , SA1->A1_LOJA                                                     , Nil})
        aadd(aSA1Auto, {"A1_CEP"    , StrTran(Iif(Empty(oJson[ 'cep' ]), 'N/A' ,oJson[ 'cep' ]) ,"-")  , Nil})
        aadd(aSA1Auto, {"A1_END"    , Iif(Empty(oJson[ 'logradouro' ]), 'N/A' ,oJson[ 'logradouro' ])  , Nil})
        aadd(aSA1Auto, {"A1_BAIRRO" , Iif(Empty(oJson[ 'bairro' ]), 'N/A' ,oJson[ 'bairro' ])          , Nil})
        aadd(aSA1Auto, {"A1_COMPLEM", Iif(Empty(oJson[ 'complemento' ]), 'N/A' ,oJson[ 'complemento' ]), Nil})
        aadd(aSA1Auto, {"A1_EST"    , oJson[ 'uf' ]                                                    , Nil})
        aadd(aSA1Auto, {"A1_MUN"    , oJson[ 'localidade' ]                                            , Nil})

        //Atualização do cliente.
        MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto)
        
        If lMsErroAuto          
            u_TECA01MSG('Falha na atualização de endereço do cliente '+SA1->A1_NOME+', por favor aguarde alguns instantes e tente novamente.', ::cOrigem)
            lRet := .F.
        Else                   
            u_TECA01MSG('As informações de endereço do cliente '+SA1->A1_NOME+' foram atualizadas com sucesso!', ::cOrigem) 
            lRet := .T.        
        EndIf   
    EndIf 

    RestArea(aAreaSA1)

Return lRet
