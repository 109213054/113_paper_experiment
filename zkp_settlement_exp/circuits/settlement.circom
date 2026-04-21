pragma circom 2.1.6;

include "../third_party/circomlib/circuits/poseidon.circom";

template Settlement(nSeller, nBuyer) {
    // public inputs
    signal input H_price_epoch;
    signal input payToSeller[nSeller];
    signal input balDSOAbs;

    // private witness
    signal input price;
    signal input rPrice;
    signal input saltPrice;
    signal input sellActual[nSeller];
    signal input buyActual[nBuyer];

    signal buyerPay[nBuyer];
    signal sellerAcc[nSeller + 1];
    signal buyerAcc[nBuyer + 1];
    signal sellerSum;
    signal buyerSum;

    // Price commitment check
    component priceHasher = Poseidon(3);
    priceHasher.inputs[0] <== price;
    priceHasher.inputs[1] <== rPrice;
    priceHasher.inputs[2] <== saltPrice;
    H_price_epoch === priceHasher.out;

    // Seller payout checks
    for (var i = 0; i < nSeller; i++) {
        payToSeller[i] === sellActual[i] * price;
    }

    // Buyer payment checks
    for (var j = 0; j < nBuyer; j++) {
        buyerPay[j] <== buyActual[j] * price;
    }

    // Seller accumulation
    sellerAcc[0] <== 0;
    for (var i = 0; i < nSeller; i++) {
        sellerAcc[i + 1] <== sellerAcc[i] + payToSeller[i];
    }
    sellerSum <== sellerAcc[nSeller];

    // Buyer accumulation
    buyerAcc[0] <== 0;
    for (var j = 0; j < nBuyer; j++) {
        buyerAcc[j + 1] <== buyerAcc[j] + buyerPay[j];
    }
    buyerSum <== buyerAcc[nBuyer];

    // Settlement balance check
    balDSOAbs === buyerSum - sellerSum;
}


