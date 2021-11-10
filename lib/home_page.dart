import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:ng_coin/widgets/slider_widget.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Client httpClient;
  Web3Client? ethClient;
  bool isData = false;
  int myAmount = 0;

  final myAddress = '0x6582436697029990185E7073f386769979aDbc14';
  // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
  var myData;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        'https://rinkeby.infura.io/v3/c10862bd531d46298f9db2de54525428',
        httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('assets/abi.json');
    String contractAddress = "0x47E0886578b6eFc929792B4F6098F81f6c71f0d1";
    final contract = DeployedContract(ContractAbi.fromJson(abi, 'NGCoin'),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient!
        .call(contract: contract, function: ethFunction, params: args);

    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    List<dynamic> result = await query('getBalance', []);

    myData = result[0];
    isData = true;
    setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        '0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d');

    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient!.sendTransaction(
      credentials,
      Transaction.callContract(
          contract: contract, function: ethFunction, parameters: args),
      // fetchChainIdFromNetworkId: true,
    );
    return result;
  }

  Future<String> sendCoin() async {
    var bigAmoint = BigInt.from(myAmount);
    var response = await submit("depositBalance", [bigAmoint]);

    print("Deposited");
    return response;
  }

  Future<String> withdrawCoin() async {
    var bigAmoint = BigInt.from(myAmount);
    var response = await submit("withdrawBalance", [bigAmoint]);

    print("Withdrawn");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: ZStack([
        VxBox()
            .red600
            .size(context.screenWidth, context.screenHeight * 0.3)
            .make(),
        VStack([
          (context.percentHeight * 10).heightBox,
          "\$nGCOIN".text.black.bold.xl4.center.makeCentered().py16(),
          (context.percentHeight * 0.1).heightBox,
          VxBox(
                  child: VStack([
            "Balance".text.gray700.xl2.semiBold.makeCentered(),
            10.heightBox,
            isData
                ? "\$$myData".text.gray700.xl6.semiBold.makeCentered().shimmer()
                : const CircularProgressIndicator().centered(),
          ]))
              .p16
              .white
              .size(context.screenWidth, context.percentHeight * 18)
              .rounded
              .shadowXl
              .make()
              .p16(),
          30.heightBox,
          SliderWidget(
            min: 0,
            max: 100,
            finalVal: (value) {
              setState(() {
                myAmount = (value * 100).round();
              });
              myAmount = (value * 100).round();
              log(myAmount.toString());
            },
          ).centered(),
          30.heightBox,
          HStack(
            [
              ElevatedButton.icon(
                onPressed: () => getBalance(myAddress),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: "Refresh".text.white.make(),
              ).h(50),
              ElevatedButton.icon(
                onPressed: () => sendCoin(),
                icon: const Icon(
                  Icons.call_made_outlined,
                  color: Colors.white,
                ),
                label: "Deposit".text.white.make(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
              ).h(50),
              ElevatedButton.icon(
                onPressed: () => withdrawCoin(),
                icon: const Icon(
                  Icons.call_received_outlined,
                  color: Colors.white,
                ),
                label: "Withdraw".text.white.make(),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
              ).h(50),
            ],
            alignment: MainAxisAlignment.spaceAround,
            axisSize: MainAxisSize.max,
          ),
        ]),
      ]),
    );
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
