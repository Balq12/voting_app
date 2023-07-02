import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import 'candidate.dart';

class ContractLink {
  String rpcUrl = 'https://alfajores-forno.celo-testnet.org';
  String wsUrl = 'wss://alfajores-forno.celo-testnet.org/ws';

  late Web3Client _client;
  late DeployedContract _contract;
  late Credentials _credentials;

  ContractLink() {
    _client = Web3Client(rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });

    _getContract();
  }

  _getContract() async {
    String abiString = await rootBundle.loadString('assets/ABI.json');
    var abi = jsonDecode(abiString);

    String contractAddress =
        "0x76e5BA35b5dc50968B031E940C92882351FB29E6"; // replace with your contract address

    _contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'Voting'),
      EthereumAddress.fromHex(contractAddress),
    );

    _credentials = EthPrivateKey.fromHex(
        '88093061c7ffd4701cd6c37532868e34043ad3f57ab3f2c08e1d290401b2a7b4');
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final function = _contract.function(functionName);
    return _client.call(contract: _contract, function: function, params: args);
  }

  Future<void> submit(String functionName, List<dynamic> args) async {
    final function = _contract.function(functionName);
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: args,
      ),
      chainId: 44787,
    );
  }

  Future<List<Candidate>> getCandidates() async {
    List<Candidate> candidatesList = [];
    var candidatesCount = await query('candidatesCount', []);

    for (var i = 1; i <= int.parse(candidatesCount[0].toString()); i++) {
      var temp = await query('candidates', [BigInt.from(i)]);
      candidatesList.add(Candidate.fromArray(temp));
    }

    return candidatesList;
  }

  Future<void> vote(int candidateId) async {
    await submit('vote', [BigInt.from(candidateId)]);
  }
}
