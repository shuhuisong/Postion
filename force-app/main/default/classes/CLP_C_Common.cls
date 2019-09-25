public with sharing class CLP_C_Common {

    private static final String HTTP_REQUEST_METHOD = 'POST';
    private static final Integer HTTP_REQUEST_TIMEOUT = Integer.valueOf(Label.CLP_HttpRequestTimeoutLabel);
    public static final String HTTP_CONNECTION_ERROR = 'http connection error';
    private static final String USER_ID_KEY = 'user_id';
    private static final String ACCESS_KEY_KEY = 'access_key';
    private static final String ERROR_KEY = 'error';
    private static final String ERROR_CODE_KEY = 'code';
    private static final String ERROR_MESSAGE_KEY = 'message';

    public static final String DEMAND_IN_EDIT = '0'; //未連携・更新情報未連携
    public static final String DEMAND_DATA_DEFECT = '1'; //データ不備
    public static final String DEMAND_LINK_AWAITING = '2'; //連携待ち
    public static final String DEMAND_LINK_SUCCESS = '3'; //連携成功
    public static final String DEMAND_FAILED_DATA_DEFECT = '4'; //連携失敗（データ不備）
    public static final String DEMAND_FAILED_INTERFACE = '5'; //連携失敗（通信エラー）
    // InfoSyncFlag__c
    public static final String FLG_UNSYNC = '0'; // 未同期
    public static final String FLG_SYNCING = '1'; // 同期中
    //API path
    public static final String GOODS_BULK_UPSERT_PATH = '/api/v1.0/goods/bulk_upsert2';
    // MikataInteBuffer__c SObjectType__c
    public static final String SOBJECT_OBICCONTRACT = 'ObicContractSpecification__c';
    public static final String SOBJECT_LOGGER = 'Logger__c';
    private static final String CONFIG_BLANK_ERROR_MESSAGE = '請求管理ロボへの接続情報を入力してください。';
    private static final String HOST_BLANK_ERROR_MESSAGE = 'カスタム設定「経理のミカタ設定」の「APIホスト」を設定してください。';
    public static MikataConfig__c mikataConfig = MikataConfig__c.getInstance(getProfileAdmin())!=null
    ? MikataConfig__c.getInstance(getProfileAdmin())
    : new MikataConfig__c();
    public static final String ENV_PREFIX = getPrefix();
    public String host;
    public String userId;
    public String accessKey;
    public String taxRate;
    // 配置情報のチェック
    public void checkConfigApi() {
        
        if (mikataConfig != null) {
            host = mikataConfig.ApiHost__c;
            userId = mikataConfig.ApiUserId__c;
            accessKey = mikataConfig.ApiAccessKey__c;
            taxRate = (mikataConfig.Tax__c == null) ? null : String.valueOf(mikataConfig.Tax__c);
        } else {
            throw new CLP_C_ContractItemApiException(CONFIG_BLANK_ERROR_MESSAGE);
        }
        if (String.isBlank(host)
            || String.isBlank(userId)
            || String.isBlank(accessKey)) {
            throw new CLP_C_ContractItemApiException(CONFIG_BLANK_ERROR_MESSAGE);
        }
    }
    // get package prefix
    public static String getPrefix(){
        ApexClass cs =[select NamespacePrefix from ApexClass where Name =:'CLP_CommonUtil'];
        String nameSpacePrefix = cs.NamespacePrefix;
        if(String.isEmpty(nameSpacePrefix)) {
            nameSpacePrefix = '';
        } else {
            nameSpacePrefix+='__';
        }
        return nameSpacePrefix;
    }
    // check FLS
    public enum FLSType {CREATE_OBJECT, UPDATE_OBJECT}
    public static Boolean checkFLS(String objectName, String[] listUpdatedFields, FLSType type)
    {
        //objectName = ENV_PREFIX + objectName;
        objectName = objectName.contains('__c') ? ENV_PREFIX + objectName : objectName;
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> m = objType.getDescribe().fields.getMap();
        if(type == FLSType.CREATE_OBJECT){
            for(String field : listUpdatedFields){
                if(field.contains('__')){ //custom field
                    if(!m.get(ENV_PREFIX + field).getDescribe().isCreateable()){
                        system.debug('##### error CREATE_OBJECT: field ' + field  + ' is not creatable');
                        return false;
                    }
                } else { //standard field
                    if(!m.get(field).getDescribe().isCreateable()){
                        return false;
                    }
                }
            }
        }
        if(type == FLSType.UPDATE_OBJECT){
            for(String field : listUpdatedFields){
                //system.debug(field);
                if(field.contains('__')){ //custom field
                    if(!m.get(ENV_PREFIX + field).getDescribe().isUpdateable()){
                        system.debug('##### error UPDATE_OBJECT: field ' + field  + ' is not updateable');
                        return false;
                    }
                } else { // standard field
                    if(!m.get(field).getDescribe().isUpdateable()){
                        return false;
                    }
                }
            }
        }
        return true;
    }
    // get profile administartor
    private static Id getProfileAdmin(){
        Profile p = [select Id from Profile where Name = 'System Administrator' OR Name = 'システム管理者'];
        return p.Id;
    }
    // get api endpoint
    public String getEndpoint(String apiPath) {
        return this.host + apiPath;
    }
    // API実行
    public String runApi(String endpoint, String requestBody) {
        try{
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(HTTP_REQUEST_METHOD);
        request.setTimeout(HTTP_REQUEST_TIMEOUT);
        request.setBody(requestBody);

        Http h = new Http();
        HttpResponse response = h.send(request);
        system.debug(response.getBody());
        Map<String, Object> responseBodyMap = getBodyMap(response.getBody());

        String errorMessage = getErrorMessage(responseBodyMap);

        if (String.isNotBlank(errorMessage)) {
            throw new CLP_C_ContractItemApiException(errorMessage);
        }
        return response.getBody();
        }catch(Exception ex){
            system.debug('ErrorMessage:' + ex.getMessage());
            throw ex;
        }
    }

    private static String getErrorMessage(Map<String, Object> bodyMap) {
        //system.debug('bodyMap:'+ bodyMap);
        Map<String, Object> errorMap = (Map<String, Object>)bodyMap.get(ERROR_KEY);
        String errorMessage;
        //system.debug('errorMap:'+ errorMap);
        if (errorMap != null) {
            Integer errorCode = (Integer)errorMap.get(ERROR_CODE_KEY);
            errorMessage = String.valueOf(errorCode) + ': ' + (String)errorMap.get(ERROR_MESSAGE_KEY);
        }
        return errorMessage;
    }

    // レスポンスをApexオブジェクトに変換する
    private static Map<String, Object> getBodyMap(String jsonBody) {
        return (Map<String, Object>)Json.deserializeUntyped(jsonBody);
    }

}