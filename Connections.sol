  pragma solidity 0.4.23;

  // ------------------------------------------------------------------------
  //  A contract to keep track of connections between Ethereum accounts
  //  Uses event logs to store address information
  // ------------------------------------------------------------------------
  contract Connections {

    // ------------------------------------------------------------------------
    //  Boolean storage representing pairing requests and connections
    // ------------------------------------------------------------------------
  	mapping (bytes32 => bool) public requested;
    mapping (bytes32 => bool) public connected;


    // ------------------------------------------------------------------------
    //  Request a pairing with address _to
    // ------------------------------------------------------------------------
    function requestConnection(address _to)
    public {
      bytes32 pairHash = getPairHash(msg.sender, _to);
      require(!connected[pairHash]);
      requested[keccak256(pairHash, msg.sender)] = true;
      emit LogNewRequest(_to, msg.sender);
    }

    // ------------------------------------------------------------------------
    //  Create a pairing between these two addresses
    // ------------------------------------------------------------------------
    function acceptConnection(address _from)
    public {
    	bytes32 pairHash = getPairHash(msg.sender, _from);
    	require(requested[keccak256(pairHash, _from)]);
      delete requested[keccak256(pairHash, _from)];
    	connected[pairHash] = true;
    	emit LogNewConnection(_from, msg.sender);
    }

    // ------------------------------------------------------------------------
    //  Remove pairing between these two addresses
    // ------------------------------------------------------------------------
    function removeConnection(address _connection)
    public {
    	bytes32 pairHash = getPairHash(msg.sender, _connection);
    	require(connected[pairHash]);
    	delete connected[pairHash];
    	emit LogConnectionEnded(msg.sender, _connection);
    }

    // ------------------------------------------------------------------------
    //  Finds the common hash between these two addresses
    // ------------------------------------------------------------------------
    function getPairHash(address _a, address _b)
    public
    pure
    returns (bytes32){
    	return (_a < _b) ? keccak256(_a, _b) :  keccak256(_b, _a);
    }

    // ------------------------------------------------------------------------
    //  Returns the request hash for user requesting connection
    // ------------------------------------------------------------------------
    function getRequestHash(address _requester, address _b)
    public
    pure
    returns (bytes32){
      bytes32 pairHash = getPairHash(_requester, _b);
      return keccak256(pairHash, _requester);
    }

    // ------------------------------------------------------------------------
    //  Events
    // ------------------------------------------------------------------------
    event LogNewRequest(address indexed _to, address indexed _from);
    event LogNewConnection(address indexed _requester, address indexed _accepter);
    event LogConnectionEnded(address indexed _disconnector, address indexed _oldConnection);

  }
