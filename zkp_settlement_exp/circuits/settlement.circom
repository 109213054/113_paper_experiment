pragma circom 2.1.6;

include "../third_party/circomlib/circuits/poseidon.circom";

template Settlement(nSeller, nBuyer) {
    // public inputs
    signal input H_price_epoch;
    signal input mActualSell[nSeller];
    signal input mActualBuy[nBuyer]; 
    signal input payToSeller[nSeller];
    signal input balDSOAbs;

    // private witness
    signal input price;
    signal input rPrice;
    signal input saltPrice;
    
    signal input sid[nSeller];
    signal input sellActual[nSeller];
    signal input rSell[nSeller];
    signal input saltSell[nSeller]; 

    signal input bid[nBuyer];
    signal input buyActual[nBuyer];
    signal input rBuy[nBuyer];
    signal input saltBuy[nBuyer]; 

    signal buyerPay[nBuyer];
    signal sellerAcc[nSeller + 1];
    signal buyerAcc[nBuyer + 1];
    signal sellerSum;
    signal buyerSum;

    component priceHasher = Poseidon(3);
    component sellHasher[nSeller];
    component buyHasher[nBuyer]; 

    // Price commitment check
    priceHasher.inputs[0] <== price;
    priceHasher.inputs[1] <== rPrice;
    priceHasher.inputs[2] <== saltPrice;
    H_price_epoch === priceHasher.out;

    // Seller commitment + payout checks
    for (var i = 0; i < nSeller; i++) {
        sellHasher[i] = Poseidon(4);
        sellHasher[i].inputs[0] <== sid[i];
        sellHasher[i].inputs[1] <== sellActual[i];
        sellHasher[i].inputs[2] <== rSell[i];
        sellHasher[i].inputs[3] <== saltSell[i];
        mActualSell[i] === sellHasher[i].out;

        payToSeller[i] === sellActual[i] * price; 
    }

    // buyer commitments + internal payment
    for (var j = 0; j < nBuyer; j++) {
        buyHasher[j] = Poseidon(4);
        buyHasher[j].inputs[0] <== bid[j];
        buyHasher[j].inputs[1] <== buyActual[j];
        buyHasher[j].inputs[2] <== rBuy[j];
        buyHasher[j].inputs[3] <== saltBuy[j];
        mActualBuy[j] === buyHasher[j].out;

        buyerPay[j] <== buyActual[j] * price;
    }

    // seller accumulation
    sellerAcc[0] <== 0;
    for (var i = 0; i < nSeller; i++) {
        sellerAcc[i + 1] <== sellerAcc[i] + payToSeller[i];
    }
    sellerSum <== sellerAcc[nSeller];

    // buyer accumulation
    buyerAcc[0] <== 0;
    for (var j = 0; j < nBuyer; j++) {
        buyerAcc[j + 1] <== buyerAcc[j] + buyerPay[j];
    }
    buyerSum <== buyerAcc[nBuyer];

    // settlement balance
    balDSOAbs === buyerSum - sellerSum;
}
