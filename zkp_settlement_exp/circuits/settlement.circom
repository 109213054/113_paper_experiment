pragma circom 2.1.6;

template Settlement(nSeller, nBuyer) {
    signal input price;

    signal input sellActual[nSeller];
    signal input buyActual[nBuyer];

    signal output payToSeller[nSeller];
    signal output balDSOAbs;

    signal buyerPay[nBuyer];
    signal totalSellerMoney;
    signal totalBuyerMoney;

    for (var i = 0; i < nSeller; i++) {
        payToSeller[i] <== sellActual[i] * price;
    }

    for (var j = 0; j < nBuyer; j++) {
        buyerPay[j] <== buyActual[j] * price;
    }

    signal sellerAcc[nSeller + 1];
    signal buyerAcc[nBuyer + 1];

    sellerAcc[0] <== 0;
    buyerAcc[0] <== 0;

    for (var i = 0; i < nSeller; i++) {
        sellerAcc[i + 1] <== sellerAcc[i] + payToSeller[i];
    }

    for (var j = 0; j < nBuyer; j++) {
        buyerAcc[j + 1] <== buyerAcc[j] + buyerPay[j];
    }

    totalSellerMoney <== sellerAcc[nSeller];
    totalBuyerMoney <== buyerAcc[nBuyer];

    balDSOAbs <== totalBuyerMoney - totalSellerMoney;
}


