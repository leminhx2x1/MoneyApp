const USER_COLLECTION = 'user';
const WALLET_COLLECTION = 'wallet';
const CATEGORY_COLLECTION = 'category';
const TRANSACTION_COLLECTION = 'transaction';
const SPEND_LIMIT_COLLECTION = 'spendLimit';

getCollectionTransaction(String? userId) =>
    '$USER_COLLECTION/$userId/$TRANSACTION_COLLECTION';

getCollectionCategory(String? userId) =>
    '$USER_COLLECTION/$userId/$CATEGORY_COLLECTION';

getCollectionAccount(String? userId) =>
    '$USER_COLLECTION/$userId/$WALLET_COLLECTION';
