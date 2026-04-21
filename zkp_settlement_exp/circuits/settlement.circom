pragma circom 2.1.6;

include "../third_party/circomlib/circuits/poseidon.circom";
include "../third_party/circomlib/circuits/comparators.circom";

template Settlement(nSeller, nBuyer) {
    // public inputs
    signal input H_price_epoch;
    signal input mActualSell[nSeller];
    signal input mActualBuy[nBuyer];
    signal input payToSeller[nSeller];
    signal input balDSOAbs;
    signal input balDSOSign;   // 0 = DSO account receivable, 1 = DSO accounts payable

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

    // internal signals
    signal buyerPay[nBuyer];
    signal sellerAcc[nSeller + 1];
    signal buyerAcc[nBuyer + 1];
    signal sellerSum;
    signal buyerSum;

    signal sellerLtBuyer;
    signal sellerEqBuyer;
    signal sellerGtBuyer;

    signal diffPayCase;       // sellerSum - buyerSum
    signal diffRecvCase;      // buyerSum - sellerSum
    signal selectedPayCase;
    signal selectedRecvCase;

    component priceHasher = Poseidon(3);
    component sellHasher[nSeller];
    component buyHasher[nBuyer];

    component ltCmp = LessThan(64);
    component eqCmp = IsEqual();

    // 1. Price commitment check
    priceHasher.inputs[0] <== price;
    priceHasher.inputs[1] <== rPrice;
    priceHasher.inputs[2] <== saltPrice;
    H_price_epoch === priceHasher.out;

    // 2. Seller commitment + payout checks
    for (var i = 0; i < nSeller; i++) {
        sellHasher[i] = Poseidon(4);
        sellHasher[i].inputs[0] <== sid[i];
        sellHasher[i].inputs[1] <== sellActual[i];
        sellHasher[i].inputs[2] <== rSell[i];
        sellHasher[i].inputs[3] <== saltSell[i];
        mActualSell[i] === sellHasher[i].out;

        payToSeller[i] === sellActual[i] * price;
    }

    // 3. Buyer commitment + internal payment
    for (var j = 0; j < nBuyer; j++) {
        buyHasher[j] = Poseidon(4);
        buyHasher[j].inputs[0] <== bid[j];
        buyHasher[j].inputs[1] <== buyActual[j];
        buyHasher[j].inputs[2] <== rBuy[j];
        buyHasher[j].inputs[3] <== saltBuy[j];
        mActualBuy[j] === buyHasher[j].out;

        buyerPay[j] <== buyActual[j] * price;
    }

    // 4. seller accumulation
    sellerAcc[0] <== 0;
    for (var i = 0; i < nSeller; i++) {
        sellerAcc[i + 1] <== sellerAcc[i] + payToSeller[i];
    }
    sellerSum <== sellerAcc[nSeller];

    // 5. buyer accumulation
    buyerAcc[0] <== 0;
    for (var j = 0; j < nBuyer; j++) {
        buyerAcc[j + 1] <== buyerAcc[j] + buyerPay[j];
    }
    buyerSum <== buyerAcc[nBuyer];

    // 6. compare sellerSum / buyerSum
    ltCmp.in[0] <== sellerSum;
    ltCmp.in[1] <== buyerSum;
    sellerLtBuyer <== ltCmp.out;

    eqCmp.in[0] <== sellerSum;
    eqCmp.in[1] <== buyerSum;
    sellerEqBuyer <== eqCmp.out;

    sellerGtBuyer <== 1 - sellerLtBuyer - sellerEqBuyer;

    // 7. sign constraints
    balDSOSign * (balDSOSign - 1) === 0;
    balDSOSign === sellerGtBuyer;

    // 8. absolute difference
    diffPayCase <== sellerSum - buyerSum;
    diffRecvCase <== buyerSum - sellerSum;

    selectedPayCase <== sellerGtBuyer * diffPayCase;
    selectedRecvCase <== sellerLtBuyer * diffRecvCase;

    balDSOAbs === selectedPayCase + selectedRecvCase;

    // When sellerEqBuyer, balDSOAbs must be 0
    sellerEqBuyer * balDSOAbs === 0;
}

