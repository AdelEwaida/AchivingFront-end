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
const getDepCountApi = "docDept/count";
const insertDepApi = "docDept/insert";
const updateDepApi = "docDept/update";
const deleteDepApi = "docDept/delete";

//Action APIs
const getActionApi = "actions/page";
const getActionCountApi = "actions/count";
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

const getFilesByHdrApi = "docFiles/getByHdr";
const getLatestFile = "docFiles/getLatestFile";
const copyFileDocApi = "docFilesTrans/copyDoc";
const deleteDocApi = "docFilesTrans/delete";
//users api
const getUserSearchApi = "users/searchCrit";
const addUserApi = "users/insert";
const deleteUserApi = "users/delete";
const updateUserApi = "users/update";
const updateUserPasswordApi = "users/changePass";
const updateOtherUserApi = "users/updateUserPass";
const getUserDepartmentApi = "userDepts/getByUser";
const setUserDepartmentApi = "userDepts/setDepts";
//docCat APIs
const getDocCategory = "docCat/getAll";

//user category
const getUserCatPageAPI = "userCategory/page";
const getUserCatCountApi = "userCategory/count";
const updateUserCatApi = "userCategory/update";
const getUsersByCat = "userCategory/getUsersByCat";
const deleteUserCatApi = "userCategory/delete";
