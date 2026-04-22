pragma circom 2.1.6;

include "../third_party/circomlib/circuits/poseidon.circom";
include "../third_party/circomlib/circuits/comparators.circom";
include "../third_party/circomlib/circuits/bitify.circom";

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
    signal input sellCase[nSeller];   // 0 -> Actual <= Claim, 1 -> Actual > Claim
    signal input buyCase[nBuyer];     // 0 -> Actual <= Claim, 1 -> Actual > Claim
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
    signal input offerId[nSeller];
    signal input claimSell[nSeller];
    signal input tSellClaim[nSeller];
    signal input saltClaimSell[nSeller];

    // seller actual layer
    signal input sellMeterId[nSeller];
    signal input sellActual[nSeller];
    signal input tSellActual[nSeller];
    signal input saltSell[nSeller];

    // buyer claim layer
    signal input orderId[nBuyer];
    signal input claimBuy[nBuyer];
    signal input tBuyClaim[nBuyer];
    signal input saltClaimBuy[nBuyer];

    // buyer actual layer
    signal input buyMeterId[nBuyer];
    signal input buyActual[nBuyer];
    signal input tBuyActual[nBuyer];
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

    // sell compare internals
    signal sellLt[nSeller];
    signal sellEq[nSeller];
    signal sellLeq[nSeller];

    // buy compare internals
    signal buyLt[nBuyer];
    signal buyEq[nBuyer];
    signal buyLeq[nBuyer];

    // -------------------------
    // components
    // -------------------------
    component priceHasher = Poseidon(5);
    component claimSellHasher[nSeller];
    component claimBuyHasher[nBuyer];
    component sellHasher[nSeller];
    component buyHasher[nBuyer];

    // range check
    component sellActualBits[nSeller];
    component claimSellBits[nSeller];
    component buyActualBits[nBuyer];
    component claimBuyBits[nBuyer];

    // sell compare
    component sellLtCmp[nSeller];
    component sellEqCmp[nSeller];

    // buy compare
    component buyLtCmp[nBuyer];
    component buyEqCmp[nBuyer];

    // DSO compare
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
    // mClaimSell[i] = Poseidon([CLAIMSELL, epoch, offerId, claimSell, tSellClaim, saltClaimSell])
    // -------------------------
    for (var i = 0; i < nSeller; i++) {
        claimSellHasher[i] = Poseidon(6);
        claimSellHasher[i].inputs[0] <== CLAIMSELL_TAG;
        claimSellHasher[i].inputs[1] <== epoch;
        claimSellHasher[i].inputs[2] <== offerId[i];
        claimSellHasher[i].inputs[3] <== claimSell[i];
        claimSellHasher[i].inputs[4] <== tSellClaim[i];
        claimSellHasher[i].inputs[5] <== saltClaimSell[i];
        mClaimSell[i] === claimSellHasher[i].out;
    }

    // -------------------------
    // 3. Buyer claim commitment
    // mClaimBuy[j] = Poseidon([CLAIMBUY, epoch, orderId, claimBuy, tBuyClaim, saltClaimBuy])
    // -------------------------
    for (var j = 0; j < nBuyer; j++) {
        claimBuyHasher[j] = Poseidon(6);
        claimBuyHasher[j].inputs[0] <== CLAIMBUY_TAG;
        claimBuyHasher[j].inputs[1] <== epoch;
        claimBuyHasher[j].inputs[2] <== orderId[j];
        claimBuyHasher[j].inputs[3] <== claimBuy[j];
        claimBuyHasher[j].inputs[4] <== tBuyClaim[j];
        claimBuyHasher[j].inputs[5] <== saltClaimBuy[j];
        mClaimBuy[j] === claimBuyHasher[j].out;
    }

    // -------------------------
    // 4. Seller actual commitment + payout checks
    // mActualSell[i] = Poseidon([ACTSELL, epoch, offerId, sellMeterId, sellActual, tSellActual, saltSell])
    // -------------------------
    for (var i = 0; i < nSeller; i++) {
        sellHasher[i] = Poseidon(7);
        sellHasher[i].inputs[0] <== ACTSELL_TAG;
        sellHasher[i].inputs[1] <== epoch;
        sellHasher[i].inputs[2] <== offerId[i];
        sellHasher[i].inputs[3] <== sellMeterId[i];
        sellHasher[i].inputs[4] <== sellActual[i];
        sellHasher[i].inputs[5] <== tSellActual[i];
        sellHasher[i].inputs[6] <== saltSell[i];
        mActualSell[i] === sellHasher[i].out;

        payToSeller[i] === sellActual[i] * price;
    }

    // -------------------------
    // 5. Buyer actual commitment + internal payment
    // mActualBuy[j] = Poseidon([ACTBUY, epoch, orderId, buyMeterId, buyActual, tBuyActual, saltBuy])
    // -------------------------
    for (var j = 0; j < nBuyer; j++) {
        buyHasher[j] = Poseidon(7);
        buyHasher[j].inputs[0] <== ACTBUY_TAG;
        buyHasher[j].inputs[1] <== epoch;
        buyHasher[j].inputs[2] <== orderId[j];
        buyHasher[j].inputs[3] <== buyMeterId[j];
        buyHasher[j].inputs[4] <== buyActual[j];
        buyHasher[j].inputs[5] <== tBuyActual[j];
        buyHasher[j].inputs[6] <== saltBuy[j];
        mActualBuy[j] === buyHasher[j].out;

        buyerPay[j] <== buyActual[j] * price;
    }

    // -------------------------
    // 6. Range checks + sell classification
    // -------------------------
    for (var i = 0; i < nSeller; i++) {
        sellActualBits[i] = Num2Bits(64);
        sellActualBits[i].in <== sellActual[i];

        claimSellBits[i] = Num2Bits(64);
        claimSellBits[i].in <== claimSell[i];

        sellLtCmp[i] = LessThan(64);
        sellLtCmp[i].in[0] <== sellActual[i];
        sellLtCmp[i].in[1] <== claimSell[i];
        sellLt[i] <== sellLtCmp[i].out;

        sellEqCmp[i] = IsEqual();
        sellEqCmp[i].in[0] <== sellActual[i];
        sellEqCmp[i].in[1] <== claimSell[i];
        sellEq[i] <== sellEqCmp[i].out;

        sellLeq[i] <== sellLt[i] + sellEq[i];

        sellCase[i] * (sellCase[i] - 1) === 0;
        sellCase[i] === 1 - sellLeq[i];
    }

    // -------------------------
    // 7. Range checks + buy classification
    // -------------------------
    for (var j = 0; j < nBuyer; j++) {
        buyActualBits[j] = Num2Bits(64);
        buyActualBits[j].in <== buyActual[j];

        claimBuyBits[j] = Num2Bits(64);
        claimBuyBits[j].in <== claimBuy[j];

        buyLtCmp[j] = LessThan(64);
        buyLtCmp[j].in[0] <== buyActual[j];
        buyLtCmp[j].in[1] <== claimBuy[j];
        buyLt[j] <== buyLtCmp[j].out;

        buyEqCmp[j] = IsEqual();
        buyEqCmp[j].in[0] <== buyActual[j];
        buyEqCmp[j].in[1] <== claimBuy[j];
        buyEq[j] <== buyEqCmp[j].out;

        buyLeq[j] <== buyLt[j] + buyEq[j];

        buyCase[j] * (buyCase[j] - 1) === 0;
        buyCase[j] === 1 - buyLeq[j];
    }

    // -------------------------
    // 8. Seller accumulation
    // -------------------------
    sellerAcc[0] <== 0;
    for (var i = 0; i < nSeller; i++) {
        sellerAcc[i + 1] <== sellerAcc[i] + payToSeller[i];
    }
    sellerSum <== sellerAcc[nSeller];

    // -------------------------
    // 9. Buyer accumulation
    // -------------------------
    buyerAcc[0] <== 0;
    for (var j = 0; j < nBuyer; j++) {
        buyerAcc[j + 1] <== buyerAcc[j] + buyerPay[j];
    }
    buyerSum <== buyerAcc[nBuyer];

    // -------------------------
    // 10. Compare sellerSum / buyerSum
    // -------------------------
    ltCmp.in[0] <== sellerSum;
    ltCmp.in[1] <== buyerSum;
    sellerLtBuyer <== ltCmp.out;

    eqCmp.in[0] <== sellerSum;
    eqCmp.in[1] <== buyerSum;
    sellerEqBuyer <== eqCmp.out;

    sellerGtBuyer <== 1 - sellerLtBuyer - sellerEqBuyer;

    // -------------------------
    // 11. Sign constraints
    // -------------------------
    balDSOSign * (balDSOSign - 1) === 0;
    balDSOSign === sellerGtBuyer;

    // -------------------------
    // 12. Absolute difference
    // -------------------------
    diffPayCase <== sellerSum - buyerSum;
    diffRecvCase <== buyerSum - sellerSum;

    selectedPayCase <== sellerGtBuyer * diffPayCase;
    selectedRecvCase <== sellerLtBuyer * diffRecvCase;

    balDSOAbs === selectedPayCase + selectedRecvCase;
    sellerEqBuyer * balDSOAbs === 0;
}
