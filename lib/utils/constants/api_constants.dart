const logInApi = "users/login";
const logOutApi = "users/logout";
const logInWitoutPassApi = "users/loginByRefUser";
////categoris api's
const categoriesTreeApi = "docCat/getTree";
const inseartCategoryApi = "docCat/insert";
const updateCategoryApi = "docCat/update";
const deleteCategoryApi = "docCat/delete";

////departemnt api's
const getDepPageApi = "docDept/page";
const searchDepPageApi = "docDept/searchCrit";

const getDepCountApi = "docDept/count";
const insertDepApi = "docDept/insert";
const updateDepApi = "docDept/update";
const deleteDepApi = "docDept/delete";
const totalDepApi = "docDept/count";
//Action APIs
const getActionApi = "actions/page";
const getActionCountApi = "actions/count";
const getActionCountByDateApi = "actions/countByDate";

const addActionApi = "actions/insert";
const deleteActionApi = "actions/delete";
const updateActionApi = "actions/update";
const getActionByDate = "actions/getByDate";

//docFiles APIs
const inserttDocFile = "docFilesTrans/insert";
const uplodeFileInDocApi = "docFilesTrans/uploadFile";
const updateDoc = "docInfo/update";
const searchDocCritereaFile = "docInfo/searchCrit";
const searchByContentApi = "docInfo/searchByContent";
// const getInfoCount = "docInfo/count";
const searchDocCountFile = "docInfo/searchCrit/count";
const searchByContentDocCountFile = "docInfo/searchCrit/count";

const getFilesByHdrApi = "docFiles/getByHdr";
const getLatestFile = "docFiles/getLatestFile";
const copyFileDocApi = "docFilesTrans/copyDoc";
const deleteDocApi = "docFilesTrans/delete";
const createWorkFlowDoc = "docFilesTrans/createWorkflow";
//users api
const getUserSearchApi = "users/searchCrit";
const addUserApi = "users/insertUserWithDepts";
const deleteUserApi = "users/delete";
const updateUserApi = "users/updateUserWithDepts";
const updateUserPasswordApi = "users/changePass";
const updateOtherUserApi = "users/updateUserPass";
const getUserDepartmentApi = "userDepts/getByUser";
const getUserSelectedDepartmentApi = "userDepts/getByUserSelected";

const setUserDepartmentApi = "userDepts/setDepts";
const getUsersCount = "users/count";
//docCat APIs
const getDocCategory = "docCat/getAll";
const deleteFileApi = "docFiles/delete";
const getDocCategoryCount = "docCat/count";
const totlaFilesApi = "docFiles/count";
//user category
const getUserCatPageAPI = "userCategory/page";
const getUserCatCountApi = "userCategory/count";
const getTotalUserCatCount = "docCat/count";
const updateUserCatApi = "userCategory/update";
const getUsersByCat = "userCategory/getUsersByCat";
const deleteUserCatApi = "userCategory/delete";

const getAllScanners = "users/getScanners";
const getScanedImageApi = "users/scanProcess";

//report apis
const getUserDocsAPI = "report/userDocs";
const getDocsByCat = "report/docsByCat";
const getDocsByDept = "report/docsByDept";
//'
const whatsAppSendPath = "send/whatsup";
const emailPath = "send/email";

const setup = "setup";
const updateSetup = "setup/update";

//templates
const createTemplate = "workflowTemplateTransactions/create";
const updateTemplate = "workflowTemplateTransactions/update";
const deleteTemplate = "workflowTemplateTransactions/delete";
const getTemplates = "workflowTemplateInfo/searchCrit";
const getTemplatesCount = "workflowTemplateInfo/count";

const getWorkFlowDoc = "workflowDocumentInfo/searchCrit";
const updateWorkFlowDoc = "workflowTransactions/update";
const deleteWorklowDoc = "workflowTransactions/delete";
const userWorkFlowSteps = "workflowDocumentSteps/getByUser";
const updateWorkFlowStep = "workflowDocumentSteps/updateStep";
const allUserWorkFlowSteps = "workflowDocumentSteps/searchCrit";
const importIssuesApi = "excel/issuesArchivedReport";
