pragma circom 2.1.6;

include "../third_party/circomlib/circuits/poseidon.circom";
include "../third_party/circomlib/circuits/comparators.circom";

template Settlement(nSeller, nBuyer) {
    // -------------------------
    // public inputs
    // -------------------------
    signal input epoch;
    signal input H_price_epoch;
    signal input mClaimSell[nSeller];
    signal input mClaimBuy[nBuyer];
    signal input mActualSell[nSeller];
    signal input mActualBuy[nBuyer];
    signal input payToSeller[nSeller];
    signal input balDSOAbs;
    signal input balDSOSign;   // 0 = DSO 應收, 1 = DSO 應付

    // -------------------------
    // private witness
    // -------------------------
    signal input price;
    signal input rPrice;
    signal input saltPrice;

    // seller claim layer
    signal input sid[nSeller];
    signal input claimSell[nSeller];
    signal input rClaimSell[nSeller];
    signal input saltClaimSell[nSeller];

    // seller actual layer
    signal input sellActual[nSeller];
    signal input rSell[nSeller];
    signal input saltSell[nSeller];

    // buyer claim layer
    signal input bid[nBuyer];
    signal input claimBuy[nBuyer];
    signal input rClaimBuy[nBuyer];
    signal input saltClaimBuy[nBuyer];

    // buyer actual layer
    signal input buyActual[nBuyer];
    signal input rBuy[nBuyer];
    signal input saltBuy[nBuyer];

    // -------------------------
    // domain tag constants
    // -------------------------
    var PRICE_TAG = 297481622096;
    var CLAIMSELL_TAG = 1407448440113608084547;
    var CLAIMBUY_TAG = 6437124142104923203;
    var ACTSELL_TAG = 21475958864495425;
    var ACTBUY_TAG = 98222719910721;

    // -------------------------
    // internal signals
    // -------------------------
    signal buyerPay[nBuyer];
    signal sellerAcc[nSeller + 1];
    signal buyerAcc[nBuyer + 1];
    signal sellerSum;
    signal buyerSum;

    signal sellerLtBuyer;
    signal sellerEqBuyer;
    signal sellerGtBuyer;

    signal diffPayCase;
    signal diffRecvCase;
    signal selectedPayCase;
    signal selectedRecvCase;

    // -------------------------
    // components
    // -------------------------
    component priceHasher = Poseidon(5);
    component claimSellHasher[nSeller];
    component claimBuyHasher[nBuyer];
    component sellHasher[nSeller];
    component buyHasher[nBuyer];

    component ltCmp = LessThan(64);
    component eqCmp = IsEqual();

    // -------------------------
    // 1. Price commitment check
    // H_price_epoch = Poseidon([PRICE, epoch, price, rPrice, saltPrice])
    // -------------------------
    priceHasher.inputs[0] <== PRICE_TAG;
    priceHasher.inputs[1] <== epoch;
    priceHasher.inputs[2] <== price;
    priceHasher.inputs[3] <== rPrice;
    priceHasher.inputs[4] <== saltPrice;
    H_price_epoch === priceHasher.out;

    // -------------------------
    // 2. Seller claim commitment
    // mClaimSell[i] = Poseidon([CLAIMSELL, epoch, sid, claimSell, rClaimSell, saltClaimSell])
    // -------------------------
    for (var i = 0; i < nSeller; i++) {
        claimSellHasher[i] = Poseidon(6);
        claimSellHasher[i].inputs[0] <== CLAIMSELL_TAG;
        claimSellHasher[i].inputs[1] <== epoch;
        claimSellHasher[i].inputs[2] <== sid[i];
        claimSellHasher[i].inputs[3] <== claimSell[i];
        claimSellHasher[i].inputs[4] <== rClaimSell[i];
        claimSellHasher[i].inputs[5] <== saltClaimSell[i];
        mClaimSell[i] === claimSellHasher[i].out;
    }

    // -------------------------
    // 3. Buyer claim commitment
    // mClaimBuy[j] = Poseidon([CLAIMBUY, epoch, bid, claimBuy, rClaimBuy, saltClaimBuy])
    // -------------------------
    for (var j = 0; j < nBuyer; j++) {
        claimBuyHasher[j] = Poseidon(6);
        claimBuyHasher[j].inputs[0] <== CLAIMBUY_TAG;
        claimBuyHasher[j].inputs[1] <== epoch;
        claimBuyHasher[j].inputs[2] <== bid[j];
        claimBuyHasher[j].inputs[3] <== claimBuy[j];
        claimBuyHasher[j].inputs[4] <== rClaimBuy[j];
        claimBuyHasher[j].inputs[5] <== saltClaimBuy[j];
        mClaimBuy[j] === claimBuyHasher[j].out;
    }

    // -------------------------
    // 4. Seller actual commitment + payout checks
    // mActualSell[i] = Poseidon([ACTSELL, epoch, sid, sellActual, rSell, saltSell])
    // -------------------------
    for (var i = 0; i < nSeller; i++) {
        sellHasher[i] = Poseidon(6);
        sellHasher[i].inputs[0] <== ACTSELL_TAG;
        sellHasher[i].inputs[1] <== epoch;
        sellHasher[i].inputs[2] <== sid[i];
        sellHasher[i].inputs[3] <== sellActual[i];
        sellHasher[i].inputs[4] <== rSell[i];
        sellHasher[i].inputs[5] <== saltSell[i];
        mActualSell[i] === sellHasher[i].out;

        payToSeller[i] === sellActual[i] * price;
    }

    // -------------------------
    // 5. Buyer actual commitment + internal payment
    // mActualBuy[j] = Poseidon([ACTBUY, epoch, bid, buyActual, rBuy, saltBuy])
    // -------------------------
    for (var j = 0; j < nBuyer; j++) {
        buyHasher[j] = Poseidon(6);
        buyHasher[j].inputs[0] <== ACTBUY_TAG;
        buyHasher[j].inputs[1] <== epoch;
        buyHasher[j].inputs[2] <== bid[j];
        buyHasher[j].inputs[3] <== buyActual[j];
        buyHasher[j].inputs[4] <== rBuy[j];
        buyHasher[j].inputs[5] <== saltBuy[j];
        mActualBuy[j] === buyHasher[j].out;

        buyerPay[j] <== buyActual[j] * price;
    }

    // -------------------------
    // 6. Seller accumulation
    // -------------------------
    sellerAcc[0] <== 0;
    for (var i = 0; i < nSeller; i++) {
        sellerAcc[i + 1] <== sellerAcc[i] + payToSeller[i];
    }
    sellerSum <== sellerAcc[nSeller];

    // -------------------------
    // 7. Buyer accumulation
    // -------------------------
    buyerAcc[0] <== 0;
    for (var j = 0; j < nBuyer; j++) {
        buyerAcc[j + 1] <== buyerAcc[j] + buyerPay[j];
    }
    buyerSum <== buyerAcc[nBuyer];

    // -------------------------
    // 8. Compare sellerSum / buyerSum
    // -------------------------
    ltCmp.in[0] <== sellerSum;
    ltCmp.in[1] <== buyerSum;
    sellerLtBuyer <== ltCmp.out;

    eqCmp.in[0] <== sellerSum;
    eqCmp.in[1] <== buyerSum;
    sellerEqBuyer <== eqCmp.out;

    sellerGtBuyer <== 1 - sellerLtBuyer - sellerEqBuyer;

    // -------------------------
    // 9. Sign constraints
    // -------------------------
    balDSOSign * (balDSOSign - 1) === 0;
    balDSOSign === sellerGtBuyer;

    // -------------------------
    // 10. Absolute difference
    // -------------------------
    diffPayCase <== sellerSum - buyerSum;
    diffRecvCase <== buyerSum - sellerSum;

    selectedPayCase <== sellerGtBuyer * diffPayCase;
    selectedRecvCase <== sellerLtBuyer * diffRecvCase;

    balDSOAbs === selectedPayCase + selectedRecvCase;

    // When sellerEqBuyer, balDSOAbs must be 0
    sellerEqBuyer * balDSOAbs === 0;
}

