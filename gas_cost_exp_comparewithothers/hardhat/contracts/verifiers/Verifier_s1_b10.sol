// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 7762877194318453948744942803973288926645767548154260490074923363784110702163;
    uint256 constant alphay  = 21790108428873818727623116344679975939216975421114967023927949047344744407184;
    uint256 constant betax1  = 19849128922691626349401810729214534369000043624195146021874984448928913912521;
    uint256 constant betax2  = 21708626724240504669608244057043322895112046696160708568993644566413494212996;
    uint256 constant betay1  = 9995914079010231637953798299902703710717145788412227428488908150757888289583;
    uint256 constant betay2  = 4045278393883345611922436640287913011934416572131044846296528399130476871919;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 17723599446869914234322634256916913666072995404027638142313800308211414740171;
    uint256 constant deltax2 = 21540837376689290237240545692216705086757273106647815399626089325586476287463;
    uint256 constant deltay1 = 15362530375353676761296414183784126012278444865600611764744408187299437366084;
    uint256 constant deltay2 = 7489156915344830373050246350800057559563974946460815033139698923750321828951;

    
    uint256 constant IC0x = 20546676600098510179581624499556772928013013296815325437745467693835338759278;
    uint256 constant IC0y = 2416489261572883839176725333883870631959351008799305794608113328321094691091;
    
    uint256 constant IC1x = 7938729508588939582871122522504535856866477038071282654374324739452074520220;
    uint256 constant IC1y = 11074349217989067996785519263730424265379055182113350472652210554757273570127;
    
    uint256 constant IC2x = 5185891178156081112965298373892532390713629985122502994630523778346500145238;
    uint256 constant IC2y = 17281996160591810189805547855045047094840958674780256932641321204672734657065;
    
    uint256 constant IC3x = 13210685222561108142766900729756968019684236827730909326768907669606783226584;
    uint256 constant IC3y = 21187471517812585694073400361202744512021118692467199673729723613520101536015;
    
    uint256 constant IC4x = 9662278401427964653688332713289965832222789225556622666511847509706176463766;
    uint256 constant IC4y = 8430392907832833140847874486045184677102465010217735157283825476936857045748;
    
    uint256 constant IC5x = 6116704371200407499928354301470899529350274564669570195706241683719898079716;
    uint256 constant IC5y = 16287783578542989381147224241067467645066846538890660397915081247123190531392;
    
    uint256 constant IC6x = 17250905968248222115306950615781554459565837081003078405245289833237344958868;
    uint256 constant IC6y = 2339528859162797244383938905180047256775201514919841852161523990856249360890;
    
    uint256 constant IC7x = 773944754750510946244818405453026291532289317349982058808542840035557596551;
    uint256 constant IC7y = 12462680323454850948177855605399480690706019374885915601105291760992080216395;
    
    uint256 constant IC8x = 20976753649241200678177299980075245613794369814424711165025505399376402534230;
    uint256 constant IC8y = 6399668365362981451815972761018449384032208836315267288087922026058759854799;
    
    uint256 constant IC9x = 8403633816466143137584890334437695453277838582955265084572232945499195361540;
    uint256 constant IC9y = 8684776099770548298518169687151949473285458919092721296084115295195373578767;
    
    uint256 constant IC10x = 38108873454243439590356641538947319237482598469698438564242804297574504274;
    uint256 constant IC10y = 21349734241677363269939066087483739789759450770609642730965923619448177434829;
    
    uint256 constant IC11x = 9455031156310624701851164087002066561227805065655110108795905082018783236318;
    uint256 constant IC11y = 17935609631782059858098825332320838883756600574399302346866708509836856785969;
    
    uint256 constant IC12x = 7501314446985487509332198611550880334351972501860799052190626551481278561573;
    uint256 constant IC12y = 11291939150483472792082918061595262368497538928386570805092032945402305717544;
    
    uint256 constant IC13x = 12014421727592861731326578482875633175048430081333471007910065354442675881994;
    uint256 constant IC13y = 10485485046017290994138405264898968793224904024439253858839902776823683308873;
    
    uint256 constant IC14x = 2461156742570068808184899697992877090782793844062053817814056718368610223884;
    uint256 constant IC14y = 8512183063623079646425606852418799907488873668203186012774407944998381596868;
    
    uint256 constant IC15x = 8203141393621309021963660745372771578132412301444713275989452670731804435763;
    uint256 constant IC15y = 16283989122953639923714367115554626897738599603502901035650479940261064265934;
    
    uint256 constant IC16x = 8691731313211045120651641368276193737385866424902078626695871678438621654225;
    uint256 constant IC16y = 13556022334997473057091083850586873070087931836663381008183423869134580451074;
    
    uint256 constant IC17x = 8878061651204257748859027339686738452533298785786353415290419359838557755824;
    uint256 constant IC17y = 16119608189151531877700715620418720451225594938421684681596212884623727261593;
    
    uint256 constant IC18x = 3256602374209680347322098348147367301697612909119594892915424381122532624790;
    uint256 constant IC18y = 2417214549808470280173973970630167817238597812432985528385754998680750045610;
    
    uint256 constant IC19x = 21678978210690685251924100088529316752795391269633962558853870597480605070253;
    uint256 constant IC19y = 16863313667121259106513908636302605167921553952840642069068602517606479833310;
    
    uint256 constant IC20x = 8361596915858047355866992234423960404123568913360032099326776514828555861466;
    uint256 constant IC20y = 11034592803406466611560527891063357655109159438162688231839143838883104800952;
    
    uint256 constant IC21x = 8873298176281043923182968360201716430034253181211768251795749357021812320203;
    uint256 constant IC21y = 6246201132893793940066254114664232138840298184080806072342480566894403211513;
    
    uint256 constant IC22x = 12718814860259685172167420274146469608298116728080403539148770150249755881669;
    uint256 constant IC22y = 14981080129279036953334028502127753966650964720697762452569822696590378073395;
    
    uint256 constant IC23x = 1826313826335901921086970920275653677741624285231716112748739975507440644216;
    uint256 constant IC23y = 10233071185426203190744353871640848046221005597831035234005853607289888444023;
    
    uint256 constant IC24x = 4247858081746110511090264406646072656085187267157300371149180838441411338526;
    uint256 constant IC24y = 3045622456128707281694891890858117192499284078967314196806894241676807297505;
    
    uint256 constant IC25x = 10575856566452148719275789790510897447108625238535444620961487459249753718727;
    uint256 constant IC25y = 9315224420470953052974860699268201765085657980290530578495199192391556900786;
    
    uint256 constant IC26x = 338160605510383481189114241983249478189479780449854267157369859932059711400;
    uint256 constant IC26y = 1532430708788100171499920996960064499537377740580118748411915669098331030903;
    
    uint256 constant IC27x = 9791709357730349878668753915350330162394731333324010081566457886987729588816;
    uint256 constant IC27y = 11108466355245276556182587007056728425300996301173248483962874448980327261599;
    
    uint256 constant IC28x = 8190073536584176801791339183290384978716744336385835396359122771672587631129;
    uint256 constant IC28y = 11524220516581796583593467738779207119790133186196080705912135032059384243828;
    
    uint256 constant IC29x = 17391726428602908337737675583645421544973988325610959221866335147704825244814;
    uint256 constant IC29y = 15913029248640556904501170337310150329515054804763275924710400883437799177744;
    
    uint256 constant IC30x = 15639330013736084985565014781814901014025947372884610278640153542690175020724;
    uint256 constant IC30y = 4680335905716231973963410872617557476901228901252045150108805976339603085505;
    
    uint256 constant IC31x = 1713124204272625695167366008535856213367490393535372856554517789941590448443;
    uint256 constant IC31y = 1237834426990669562772767756835807517120844817469605414778722419338524996865;
    
    uint256 constant IC32x = 11608972818538789522461476524022714108960451586086537276381402525423518283638;
    uint256 constant IC32y = 18601638358469276741674454945788091854433735764129822034502842041590654522749;
    
    uint256 constant IC33x = 2939865140031844565442737175224550925424335314695364758483510155490397123569;
    uint256 constant IC33y = 20427320775104953088961196603421638100640886426132356802711060862796730593183;
    
    uint256 constant IC34x = 2870709809309888455383712292521879813927253606695367813088744307416179923418;
    uint256 constant IC34y = 17606420892090557721068164054302876054701819822078521780854127647276231483454;
    
    uint256 constant IC35x = 14197429617486205136527472559458423619732276872390264229055924159376024241541;
    uint256 constant IC35y = 7069225721267808921409818519587538237207250772177334745845084415139654122628;
    
    uint256 constant IC36x = 6222575545466445390289911556839504377940158254624916041615767954870165016449;
    uint256 constant IC36y = 12852972594875495440356699148927624984978377969803028611383727923853351447702;
    
    uint256 constant IC37x = 18300375144414620194702956377298155234183184338395288794405064462744511252476;
    uint256 constant IC37y = 16556648390631865202874137459557421043828389848175721645859215473133343738833;
    
    uint256 constant IC38x = 7761456518066533169016428093460891714149929956790017912009866688374097678419;
    uint256 constant IC38y = 7040442560184536780692300609925945136288693582508072434827743738019424979447;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[38] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                
                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))
                
                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))
                
                g1_mulAccC(_pVk, IC28x, IC28y, calldataload(add(pubSignals, 864)))
                
                g1_mulAccC(_pVk, IC29x, IC29y, calldataload(add(pubSignals, 896)))
                
                g1_mulAccC(_pVk, IC30x, IC30y, calldataload(add(pubSignals, 928)))
                
                g1_mulAccC(_pVk, IC31x, IC31y, calldataload(add(pubSignals, 960)))
                
                g1_mulAccC(_pVk, IC32x, IC32y, calldataload(add(pubSignals, 992)))
                
                g1_mulAccC(_pVk, IC33x, IC33y, calldataload(add(pubSignals, 1024)))
                
                g1_mulAccC(_pVk, IC34x, IC34y, calldataload(add(pubSignals, 1056)))
                
                g1_mulAccC(_pVk, IC35x, IC35y, calldataload(add(pubSignals, 1088)))
                
                g1_mulAccC(_pVk, IC36x, IC36y, calldataload(add(pubSignals, 1120)))
                
                g1_mulAccC(_pVk, IC37x, IC37y, calldataload(add(pubSignals, 1152)))
                
                g1_mulAccC(_pVk, IC38x, IC38y, calldataload(add(pubSignals, 1184)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            
            checkField(calldataload(add(_pubSignals, 800)))
            
            checkField(calldataload(add(_pubSignals, 832)))
            
            checkField(calldataload(add(_pubSignals, 864)))
            
            checkField(calldataload(add(_pubSignals, 896)))
            
            checkField(calldataload(add(_pubSignals, 928)))
            
            checkField(calldataload(add(_pubSignals, 960)))
            
            checkField(calldataload(add(_pubSignals, 992)))
            
            checkField(calldataload(add(_pubSignals, 1024)))
            
            checkField(calldataload(add(_pubSignals, 1056)))
            
            checkField(calldataload(add(_pubSignals, 1088)))
            
            checkField(calldataload(add(_pubSignals, 1120)))
            
            checkField(calldataload(add(_pubSignals, 1152)))
            
            checkField(calldataload(add(_pubSignals, 1184)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
