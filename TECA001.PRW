#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} User Function TECA001
    Tela de atualização de endereço de clientes com base no CEP.
    @type  User Function
    @author João Mauricio
    @since 18/01/2023
    @version 1.0
/*/
User Function TECA001()
Local oBrowse
Local aColsSA1 as Array

aColsSA1 := {;
    {FWX3Titulo( 'A1_COD' )    , {|| SA1->A1_COD }   , FWSX3Util():GetFieldStruct( 'A1_COD' )[2]    , PesqPict( 'SA1' , 'A1_COD' )    , 0, FWSX3Util():GetFieldStruct( 'A1_COD' )[3]    , FWSX3Util():GetFieldStruct( 'A1_COD' )[4]    , .F., , , , , , , , 1},;
    {FWX3Titulo( 'A1_LOJA' )   , {|| SA1->A1_LOJA}   , FWSX3Util():GetFieldStruct( 'A1_LOJA' )[2]   , PesqPict( 'SA1' , 'A1_LOJA' )   , 0, FWSX3Util():GetFieldStruct( 'A1_LOJA' )[3]   , FWSX3Util():GetFieldStruct( 'A1_LOJA' )[4]   , .F., , , , , , , , 1},;
    {FWX3Titulo( 'A1_NOME' )   , {|| SA1->A1_NOME}   , FWSX3Util():GetFieldStruct( 'A1_NOME' )[2]   , PesqPict( 'SA1' , 'A1_NOME' )   , 0, FWSX3Util():GetFieldStruct( 'A1_NOME' )[3]   , FWSX3Util():GetFieldStruct( 'A1_NOME' )[4]   , .F., , , , , , , , 1},;
    {FWX3Titulo( 'A1_CEP' )    , {|| SA1->A1_CEP}    , FWSX3Util():GetFieldStruct( 'A1_CEP' )[2]    , PesqPict( 'SA1' , 'A1_CEP' )    , 0, FWSX3Util():GetFieldStruct( 'A1_CEP' )[3]    , FWSX3Util():GetFieldStruct( 'A1_CEP' )[4]    , .F., , , , , , , , 1},;
    {FWX3Titulo( 'A1_EST' )    , {|| SA1->A1_EST}    , FWSX3Util():GetFieldStruct( 'A1_EST' )[2]    , PesqPict( 'SA1' , 'A1_EST' )    , 0, FWSX3Util():GetFieldStruct( 'A1_EST' )[3]    , FWSX3Util():GetFieldStruct( 'A1_EST' )[4]    , .F., , , , , , , , 1},;
    {FWX3Titulo( 'A1_MUN' )    , {|| SA1->A1_MUN}    , FWSX3Util():GetFieldStruct( 'A1_MUN' )[2]    , PesqPict( 'SA1' , 'A1_MUN' )    , 0, FWSX3Util():GetFieldStruct( 'A1_MUN' )[3]    , FWSX3Util():GetFieldStruct( 'A1_MUN' )[4]    , .F., , , , , , , , 1},;
    {FWX3Titulo( 'A1_END' )    , {|| SA1->A1_END}    , FWSX3Util():GetFieldStruct( 'A1_END' )[2]    , PesqPict( 'SA1' , 'A1_END' )    , 0, FWSX3Util():GetFieldStruct( 'A1_END' )[3]    , FWSX3Util():GetFieldStruct( 'A1_END' )[4]    , .F., , , , , , , , 1},;
    {FWX3Titulo( 'A1_BAIRRO' ) , {|| SA1->A1_BAIRRO} , FWSX3Util():GetFieldStruct( 'A1_BAIRRO' )[2] , PesqPict( 'SA1' , 'A1_BAIRRO' ) , 0, FWSX3Util():GetFieldStruct( 'A1_BAIRRO' )[3] , FWSX3Util():GetFieldStruct( 'A1_BAIRRO' )[4] , .F., , , , , , , , 1},;
    {FWX3Titulo( 'A1_COMPLEM' ), {|| SA1->A1_COMPLEM}, FWSX3Util():GetFieldStruct( 'A1_COMPLEM' )[2], PesqPict( 'SA1' , 'A1_COMPLEM' ), 0, FWSX3Util():GetFieldStruct( 'A1_COMPLEM' )[3], FWSX3Util():GetFieldStruct( 'A1_COMPLEM' )[4], .F., , , , , , , , 1};
}

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SA1')
oBrowse:SetDescription('Validador CEP - Clientes')
oBrowse:SetFields(aColsSA1)
oBrowse:SetOnlyFields({''}) //Esconde os outros campos.
oBrowse:AddLegend( "Empty(SA1->A1_CEP)", "RED", 'CEP não preenchido.'      )
oBrowse:AddLegend( "!Empty(SA1->A1_CEP) .AND. (Empty(SA1->A1_EST) .OR. Empty(SA1->A1_MUN) .OR. Empty(SA1->A1_END) .OR. Empty(SA1->A1_BAIRRO))", "YELLOW"  , 'Cadastro de endereço incompleto.' )
oBrowse:AddLegend( "!Empty(SA1->A1_CEP) .AND. !Empty(SA1->A1_EST) .AND. !Empty(SA1->A1_MUN) .AND. !Empty(SA1->A1_END) .AND. !Empty(SA1->A1_BAIRRO)", "GREEN"  , 'Cadastro de endereço completo.' )

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.TECA001' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Atualizar Endereço por CEP (digitação)' ACTION 'U_TECA01MAN' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Atualizar endereço via CSV (em massa)'  ACTION 'U_TECA01IMP' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Legendas" ACTION 'U_TECA01LEG' OPERATION 9 ACCESS 0

Return aRotina

/*/{Protheus.doc} User Function TECA01LEG
    Legenda.
    @type  Function
    @author João Mauricio
    @since 16/01/2023
    @version 1.0
/*/
User Function TECA01LEG()
Local aLegenda:= {}

   AAdd(aLegenda, {"BR_VERMELHO", 'CEP não preenchido.'})
   AAdd(aLegenda, {"BR_AMARELO", 'Cadastro de endereço incompleto.'})
   AAdd(aLegenda, {"BR_VERDE", 'Cadastro de endereço completo.'})
   BrwLegenda("Cadastro de endereço", 'Legendas', aLegenda) //Legenda

Return   

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSA1 := FWFormStruct( 1, 'SA1', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('TECA001M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SA1MASTER', /*cOwner*/, oStruSA1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Modelo Clientes' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'SA1MASTER' ):SetDescription( 'Clientes' )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'TECA001' )
// Cria a estrutura a ser usada na View
Local oStruSA1 := FWFormStruct( 2, 'SA1', { |x| ALLTRIM(x) $ 'A1_COD, A1_LOJA, A1_NOME, A1_CEP, A1_EST, A1_MUN, A1_END, A1_BAIRRO, A1_COMPLEM' }  )

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_SA1', oStruSA1, 'SA1MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_SA1', 'TELA' )

Return oView

/*/{Protheus.doc} User Function TECA01MAN
    Atualização digitada de cep e endereço
    @type  Function
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
/*/
User Function TECA01MAN() 
    Local cOrigem := 1 //manual
    Local cCodigo := SA1->A1_COD
    Local cLoja := SA1->A1_LOJA

    oAtuCli := AtualizaCli():new(cOrigem,cCodigo,cLoja)    
    oAtuCli:montaTela()    
    oAtuCli:buscaCEP()

    If oAtuCli:valida()
        RptStatus({|| oAtuCli:realizaAlteracao()}, "Aguarde...", "Atualizado cadastro...")        
    EndIf    

    FwFreeObj(oAtuCli)
       
Return nil

/*/{Protheus.doc} User Function TECA01IMP
    Atualização em massas de cep e endereço.
    Utiliza importação de csv.    
    @type  Function
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
/*/
User Function TECA01IMP()
    Local cArqOri as Character
    //Mostra o Prompt para selecionar arquivos
    cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )
    RptStatus({|| u_TECA01CSV(cArqOri)}, "Aguarde...", "Atualizado cadastro...")      
Return nil

/*/{Protheus.doc} TECA01MSG
    Trata mensagem de acordo com a origem do processamento.
    @type  User Function
    @author João Mauricio
    @since 17/01/2023
    @version 1.0
    @param cMsg, character, Mensagem a ser exibida.
    @param cOrigem, character, Origem do processamento : 1-manual 2-importacao 3-ws  
/*/
User Function TECA01MSG(cMsg, cOrigem)
    Default cMsg := ""
    If cOrigem == 1
        MsgAlert(cMsg, 'Atualização de cadastro de cliente.' )
    Elseif cOrigem == 2
        Conout(cMsg)
    Elseif cOrigem == 3
        Conout(cMsg)
    EndIf
Return nil
