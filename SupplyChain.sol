pragma solidity >=0.4.21 <0.6.0;

contract supplyChain {
    uint32 public product_id = 0;       // Product ID
    uint32 public participant_id = 0;   // Participant ID
    uint32 public owner_id = 0;         // Ownership ID

    struct product {
        string UUID;
        string modelNumber;
        string partNumber;
        string serialNumber;
        address productOwner;
        uint32 mfgCost;
        uint32 msrp;
        uint32 mfgTimeStamp;
    }

    mapping(uint32 => product) public products;
    event NewProduct(uint32 productId, uint32 createdTimestamp);
    event UpdateProduct(string UUID, string modelNumber, string partNumber, string serialNumber,
        address productOwner, uint32 mfgCost, uint32 msrp, uint32 mfgTimeStamp);

    struct ownership {
        uint32 productId;
        uint32 ownerId;
        uint32 trxTimeStamp;
        address productOwner;
        uint32 cost;
        uint32 price;
        uint32 qty;
    }
    mapping(uint32 => ownership) public ownerships; // ownerships by ownership ID (owner_id)
    mapping(uint32 => uint32[]) public productTrack;  // ownerships by Product ID (product_id)

    struct participant {
        string UUID;
        string userName;
        string password;
        string participantType;
        address participantAddress;
    }
    mapping(uint32 => participant) public participants;

    event NewParticipant(uint32 participantId, uint32 createdTimestamp);
    event TransferOwnership(uint32 productId, address fromOwner, address toOwner);
    event UpdateParticipant(string participantUUID, string userName, string password, string participantType, address participantAddress);

    function addParticipant(string memory _UUID, string memory _name, string memory _pass, string memory _pType, address _pAdd)
        public returns (uint32){

        uint32 userId = participant_id++;
        participants[userId].UUID = _UUID;
        participants[userId].userName = _name;
        participants[userId].password = _pass;
        participants[userId].participantType = _pType;
        participants[userId].participantAddress = _pAdd;
        emit NewParticipant(participant_id, uint32(now));

        return userId;
    }

    function getParticipant(uint32 _participant_id) public view returns (string memory,string memory,string memory,address) {
        return (participants[_participant_id].UUID, participants[_participant_id].userName,
                participants[_participant_id].participantType,participants[_participant_id].participantAddress);
    }

    function addProduct(string memory _UUID, uint32 _ownerId, string memory _modelNumber, string memory _partNumber, string memory _serialNumber,
            uint32 _productCost, uint32 _productMSRP, uint32 _timestamp) public returns (uint32) {

        if(keccak256(abi.encodePacked(participants[_ownerId].participantType)) == keccak256("Manufacturer")) {
            uint32 productId = product_id++;

            products[productId].UUID = _UUID;
            products[productId].modelNumber = _modelNumber;
            products[productId].partNumber = _partNumber;
            products[productId].serialNumber = _serialNumber;
            products[productId].mfgCost = _productCost;
            products[productId].msrp = _productMSRP;
            products[productId].productOwner = participants[_ownerId].participantAddress;
            if (_timestamp == 0) {
                products[productId].mfgTimeStamp = uint32(now);
            }
            else {
                products[productId].mfgTimeStamp = _timestamp;
            }
            emit NewProduct(productId, products[productId].mfgTimeStamp);

            return productId;
        }

       return 0;
    }

    modifier onlyOwner(uint32 _productId) {
         require(msg.sender == products[_productId].productOwner,"Only the product owner can do this");
         _;
    }

    function getProduct(uint32 _productId) public view returns (string memory,string memory,string memory,string memory,uint32,address,uint32){
        return (products[_productId].UUID,products[_productId].modelNumber,products[_productId].partNumber,products[_productId].serialNumber,
            products[_productId].mfgCost,products[_productId].productOwner,products[_productId].mfgTimeStamp);
    }

    function newOwner(uint32 _prodId, uint32 _user1Id, uint32 _user2Id, uint32 _cost, uint32 _price, uint32 _qty, uint32 _timestamp)
        public onlyOwner(_prodId) returns(bool) {

        participant memory p1 = participants[_user1Id];
        participant memory p2 = participants[_user2Id];
        uint32 ownership_id = owner_id++;

        ownerships[ownership_id].productId = _prodId;
        ownerships[ownership_id].productOwner = p2.participantAddress;
        ownerships[ownership_id].ownerId = _user2Id;
        ownerships[ownership_id].cost = _cost;
        ownerships[ownership_id].price = _price;
        ownerships[ownership_id].qty = _qty;
        if (_timestamp == 0) {
            ownerships[ownership_id].trxTimeStamp = uint32(now);
        }
        else {
            ownerships[ownership_id].trxTimeStamp = _timestamp;
        }
        products[_prodId].productOwner = p2.participantAddress;
        productTrack[_prodId].push(ownership_id);
        emit TransferOwnership(_prodId, p1.participantAddress, p2.participantAddress);

        return (true);
    }

   function getProvenance(uint32 _prodId) external view returns (uint32[] memory) {
       return productTrack[_prodId];
    }

    function getOwnership(uint32 _regId)  public view returns (uint32,uint32,address,uint32) {
        ownership memory r = ownerships[_regId];
        return (r.productId,r.ownerId,r.productOwner,r.trxTimeStamp);
    }

    function authenticateParticipant(uint32 _uid, string memory _uname, string memory _pass, string memory _utype) public view returns (bool){
        if(keccak256(abi.encodePacked(participants[_uid].participantType)) == keccak256(abi.encodePacked(_utype))) {
            if(keccak256(abi.encodePacked(participants[_uid].userName)) == keccak256(abi.encodePacked(_uname))) {
                if(keccak256(abi.encodePacked(participants[_uid].password)) == keccak256(abi.encodePacked(_pass))) {
                    return (true);
                }
            }
        }

        return (false);
    }
}