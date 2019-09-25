public with sharing class CLP_C_ListViewButtonController {
    // LightningExperience上のカスタムVisualforceボタンを実行する上での処理を定義
    // (詳細ページのアクション、リストボタン等で使用)

    // Visualforceコンポーネント用カスタムコントローラーコンストラクタ
    public CLP_C_ListViewButtonController() {

    }
    // 共通クラス変数
    public static string prefix {get;set;}
    public static string prefixObj {get;set;}

    // 【リストボタン用処理】
    ApexPages.StandardSetController setCon;
    public static List<String> selectedIdList {get;set;}
    public static List<String> validationIdList {get;set;}
    public static boolean isSelected {get;set;}
    public static string retURL {get;set;}
    // 最大選択件数
    public static Integer maxSelectedNum_200 {get;set;} // 最大200件
    // 連携対象判定フラグ
    public static boolean isNoExistTarget {get;set;}
    public static boolean isMixExistTarget {get;set;}
    public static Integer fullSelectedNum {get;set;}
    // 請求書 処理対象数
    public static Integer nonTargetBillNum {get;set;}
    public static Integer targetBillNum {get;set;}
    // 請求書 連携対象IDリスト
    public static List<String> targetBillIdList {get;set;}

    // 標準セットページ用コンストラクタ
    public CLP_C_ListViewButtonController(ApexPages.StandardSetController controller) {
        setCon = controller;
        selectedIdList = new List<String>();
        validationIdList = new List<String>();
        isSelected = false;
        prefix = '';
        prefixObj = '';
        // 名前空間取得
        getPackageNamespace();
        // 最大選択件数
        maxSelectedNum_200 = 200;
        // Classic画面向け遷移前ページ
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        isNoExistTarget = false;
        isMixExistTarget = false;
        fullSelectedNum = 0;
        nonTargetBillNum = 0;
        targetBillNum = 0;
        targetBillIdList = new List<String>();
    }

    // 商品：リストビュー複数チェック初期処理
    public Void initProduct2List(){
        List<ObicContractSpecification__c> selectObjList = new List<ObicContractSpecification__c>();
        selectObjList = setCon.getSelected();
        if(selectObjList.size() > 0){
            isSelected = true;
            for(ObicContractSpecification__c pd :selectObjList){
                selectedIdList.add('"' + pd.Id + '"');
            }
        }
    }
    // 名前空間を取得(パッケージが存在するかを判断)
    // @return 名前空間文字列
    public static String getPackageNamespace() {
        List<ApexClass> acList = [select NamespacePrefix from ApexClass where Name = 'CLP_CommonUtil' limit 1];
        if(acList.size() > 0){
            prefix = acList[0].NamespacePrefix == null ? '' : acList[0].NamespacePrefix + '.';
            prefixObj = acList[0].NamespacePrefix == null ? '' : acList[0].NamespacePrefix + '__';
        }
        return prefix;
    }
}